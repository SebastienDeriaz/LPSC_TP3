from multiprocessing.sharedctypes import Value
import numpy as np
from fractions import Fraction

from fpga import twoscomplement

def fraction_to_float(frac_str):
    try:
        return float(frac_str)
    except ValueError:
        num, denom = frac_str.split('/')
        try:
            leading, num = num.split(' ')
            whole = float(leading)
        except ValueError:
            whole = 0
        frac = float(num) / float(denom)
        return whole - frac if whole < 0 else whole + frac



def binary_multiply(A, B, signed=False):
    """
    Binary multiplication of two arrays

    Parameters
    ----------
    A, B : array_like

    Returns
    -------
    C : array_like
        A*B
    """
    C = np.zeros(A.size+B.size, dtype=np.uint8)
    for i in (A.size - 1 - np.where(A)[0])[::-1]:
        if i == A.size-1 and signed: # if this is the first bit of A (A is negative)
            B_inv = twos_complement(B)
            temp = np.block([np.ones(C.size - B.size - i, dtype=np.uint8) * B_inv[0] * signed, B_inv, np.zeros(i, dtype=np.uint8)])
        else:
            temp = np.block([np.ones(C.size - B.size - i, dtype=np.uint8) * B[0] * signed, B, np.zeros(i, dtype=np.uint8)])
        
        C, _ = binary_add(C, temp)

    return C
        



def binary_add(A, B):
    """
    Binary addition of two equal-size arrays

    Parameters
    ----------
    A, B : array_like        

    Returns
    -------
    C : array_like
        A+B
    carry : int
    """
    if A.shape != B.shape:
        raise ValueError("A and B are different shapes")
    carry = 0
    C = np.zeros_like(A)
    for i, (a, b) in enumerate(zip(A[::-1], B[::-1])):
        C[-i-1] = 1 if (a + b + carry) % 2 == 1 else 0
        carry = 1 if (a + b + carry) >= 2 else 0
        
    
    return C, carry


def twos_complement(array):
    """
    Returns the two's complement of the given bit representation

    Parameters
    ----------
    array : array_like
        bit representation of the number

    Returns
    -------
    output : array_like
        bit representation of the two's complement of the input
    """

    arr_inv = 1 - array

    output = np.zeros_like(array)
    B = np.zeros_like(array)
    B[-1] = 1
    out, _ = binary_add(arr_inv, B)
    return out


def array_to_integer(array, signed=False):
    """
    Returns the integer value corresponding to the given array

    Parameters
    ----------
    array : array_like
        bit representation of the number. array[0] is MSB
    signed : bool

    Returns
    -------
    output : int
    """
    sign = 1
    if signed and array[0] == 1:
        array = twos_complement(array)
        sign = -1

    powers = 2**(np.arange(array.size)[::-1])
    output = int(np.sum(array * powers) * sign)

    return output

def integer_to_array(integer, N, signed=False):
    """
    Returns binary representation of the given integer

    Parameters
    ----------
    integer : int
        input value
    N : int
        Number of bits
    signed : bool
        allow negative numbers
    
    Returns
    -------
    output : array_like
        binary representation
    """
    if integer < 0 and signed == False:
        raise ValueError(f"Cannot have unsigned negative number ({integer})")
    if integer == 0:
        Nbits_required = 1
    else:
        Nbits_required = np.ceil(np.log2(np.abs(integer)))
    if Nbits_required > (N - signed):
        raise ValueError(f"Number too big for {N} bits : {integer}")
    
    str_rep = np.binary_repr(np.abs(integer))
    output = np.zeros(N, dtype=np.uint8)
    output[-len(str_rep):] = np.array([int(x) for x in str_rep])
    if integer < 0:
        output = twos_complement(output)

    return output

def float_to_array(value, N, Ndecimals, signed=False):
    """
    Converts float value to binary representation

    Parameters
    ----------
    value : float, int
        Input value
    N : int
        Number of bits
    Ndecimals : int
        Number of fixed point bits
    signed : bool
        Signed number

    Returns
    -------
    output : array_like
        binary representation of the number
    """
    value_adj = int(np.round(2**Ndecimals * value))
    output = integer_to_array(value_adj, N = N, signed=signed)
    return output






def array_to_fraction(array, Ndecimals, signed=False):
    """
    Returns fractional value of the given fixed point array 

    Parameters
    ----------
    array : array_like
        input binary representation with array[0] = MSB
    Ndecimals : int
        Number of fixed point bits
    signed : bool
        Signed number of not

    Returns
    -------
    output : fraction
        Output value
    """
    output = Fraction(array_to_integer(array, signed=signed))
    if Ndecimals > 0:
        output /= 2**Ndecimals
    return output

def split_binary_blocks(string):
    binary_representation = string[:len(string) % 4]
    if len(binary_representation) > 0:
        binary_representation += "'"
    end = string[len(string) % 4:]
    for i in range(0, len(end), 4):
        if i > 0:
            binary_representation += "'"
        binary_representation += ''.join(end[i:i+4])

    return binary_representation

class number():
    def __init__(self, N, signed=False, Ndecimals=0):
        """
        Declare a binary number with size N (bits)

        Parameters
        ----------
        N : int
        signed : bool
            Signed number or not (for representation only)
        Ndecimals : int
            Number of decimals (fixed point), for representation only
            0 by default
        """
        self.N = N
        self.signed = signed
        self.Ndecimals = Ndecimals
        self._arr = np.zeros(N, dtype=np.uint8)
    
    def __copy__(self):
        return number(self.N, self.signed, self.Ndecimals)

    def __str__(self):
        binary_representation = ""
        value = array_to_fraction(self._arr, signed=self.signed, Ndecimals=self.Ndecimals)
        uvalue = array_to_integer(self._arr, signed=False)
        Nhex = int(np.ceil(self.N / 4))
        binary_representation = split_binary_blocks(''.join([str(x) for x in self._arr]))
        if self.Ndecimals > 0:
            str_value = f"{fraction_to_float(value)} ({value})"
        else:
            str_value = f"{fraction_to_float(value):.0f}"
        output = f"{binary_representation} 0x{uvalue:0{Nhex}X} {str_value}"
        return output

    def __repr__(self):
        return self.__str__()

    def bit(self, n):
        return 0

    def set(self, value, truncate=False):
        """
        Sets the value of the number

        Parameters
        ----------
        value : int or array_like
            int will be converted from base 10, array_like will be truncated if necessary
        truncate : bool
            Adjust value to the current array size
        """
        def _from_array(self, arr):
            if arr.size == self.N:
                # easy
                self._arr = arr.astype(np.uint8)
            elif arr.size > self.N:
                print(f"Truncated number {arr.size} -> {self.N}")
                self._arr = arr[-self.N:].astype(np.uint8)
            else: # size < N
                if self.signed:
                    pad = int(arr[0])
                else:
                    pad = 0
                self._arr[:] = pad
                self._arr[-arr.size:] = arr.astype(np.uint8)

        if isinstance(value, int) or isinstance(value, float):
            self._arr = float_to_array(value, self.N, self.Ndecimals, signed=self.signed)
        elif isinstance(value, np.ndarray):
            _from_array(self, value)
        elif isinstance(value, list):
            _from_array(self, np.array(value))
        elif isinstance(value, number):
            _from_array(self, value._arr)
        else:
            raise ValueError("invalid type")

    def __add__(self, otherNumber):
        """
        Adds two numbers and returns a N sized number
        """
        if otherNumber.Ndecimals != self.Ndecimals:
            raise ValueError("Can't add numbers with different number of decimals")
        C, c = binary_add(self._arr, otherNumber._arr)
        signed = True if self.signed or otherNumber.signed else False
        out = number(self.N + 1, signed=self.signed, Ndecimals=self.Ndecimals)
        out.set(C)
        return out
    
    def __mul__(self, otherNumber):
        """
        Multiply two numbers and return a Na+Nb sized number
        """
        signed = True if self.signed or otherNumber.signed else False
        C = binary_multiply(self._arr, otherNumber._arr, signed=signed)
        out = number(self.N + otherNumber.N, signed=signed, Ndecimals=self.Ndecimals + otherNumber.Ndecimals)
        out.set(C)
        return out
    
    def __sub__(self, otherNumber):
        """
        Substracts two numbers
        """
        if otherNumber.Ndecimals != self.Ndecimals:
            raise ValueError("Can't substract numbers with different number of decimals")
        C, c = binary_add(self._arr, twos_complement(otherNumber._arr))
        signed = True if self.signed or otherNumber.signed else False
        out = number(self.N + 1, signed=self.signed, Ndecimals=self.Ndecimals)
        out.set(C)
        return out

    def __neg__(self):
        new = self.__copy__()
        new.set(twos_complement(self._arr))
        return new

    def left(self, n):
        """
        Keeps only the n left bits (MSB)
        """
        removed = self.N-n
        output = number(n, signed=self.signed, Ndecimals=np.max([0, self.Ndecimals-removed]))
        output.set(self._arr[:n])
        return output

    def right(self, n):
        """
        Keeps only the right bits (LSB)
        """
        removed = self.N-n
        output = number(n, signed=self.signed, Ndecimals=np.min([self.Ndecimals, n]))
        output.set(self._arr[self.N-n:])
        return output

    def to(self, Nbits, Ndecimals):
        """
        Truncate to desired number of bits and decimals
        """
        output = number(Nbits, signed=self.signed, Ndecimals=Ndecimals)
        start = self.N - Nbits
        output.set(self._arr[:-1-Ndecimals])
        



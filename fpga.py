import numpy as np


def uint_to_arr(value, bits=8, order='big'):
    """
    Returns an array corresponding to the binary representation of a given unsigned integer

    Parameters
    ----------
    value : int
        Value to convert
    bits : int
        number of bits in the output
    order : str
        'big' means the LSB is last -> [-1] and the array is "readable" normally
        'little' means the LSB is first -> [0] and the array is flipped
    """
    # Creating a string representation of the number
    string = np.binary_repr(value)
    if len(string) > bits:
        #raise ValueError(
        #    f"Number is too big for the given number of bits : {bits}")
        pad_string = string[-bits:]
    elif len(string) < bits:
        # Adding padding zero
        pad_string = '0'*(bits-len(string)) + string
    else:
        pad_string = string
    # Convert to numpy array
    array = np.array([int(x) for x in pad_string], dtype=np.uint8)

    return (array if order == 'big' else array[::-1])


def twoscomplement(A):
    # invert all the bits
    A_inv = 1 - A
    # convert to integer and add 1
    A_out = int(np.round(array_to_float(A_inv, 0, signed=False) + 1))
    # Convert back to array
    return uint_to_arr(A_out, bits=A.size)
    

def array_to_float(arr, N_decimal_bits=0, signed=False):
    powers = np.power(2.0, np.arange(arr.size)[::-1] - N_decimal_bits)
    if signed and arr[0] > 0:
        return -np.sum(twoscomplement(arr) * powers)
    else:
        return np.sum(arr * powers)
        
def float_to_array(value, N_bits, N_decimal_bits):
    # Convert value to int
    value_int = int(np.round(np.abs(value) * 2**(N_decimal_bits)))
    arr = uint_to_arr(value_int, N_bits)
    return twoscomplement(arr) if value < 0 else arr

def multiply(A, B, N_decimal_bits, signed=False):
    value = array_to_float(A, N_decimal_bits, signed) * array_to_float(B, N_decimal_bits, signed)
    return float_to_array(value, N_bits=A.size + B.size, N_decimal_bits=2*N_decimal_bits)


class fpga():
    def __init__(self, dataSize, coefSize, Asize, Bsize, Csize, depth) -> None:
        self.Asize = Asize #(Nbits, Ndecimal)
        self.Bsize = Bsize
        self.depth = depth
        self.values = np.zeros([depth, dataSize[0]])

    def init(self, coefs):
        if coefs.size != self.values.shape[0]:
            raise ValueError(f"Invalid shape {coefs.size} / {self.values.shape[0]}")
        self.coefs = np.zeros([coefs.size, self.Nbits])
        for i, c in enumerate(coefs):
            self.coefs[i, :] = float_to_array(c, N_bits=self.Nbits, N_decimal_bits=self.Ndecimals)
        

    def _calc_values(self):
        products = [array_to_float(multiply(v, c, N_decimal_bits=self.Ndecimals, signed=True)[self.Nbits-self.Ndecimals:-self.Ndecimals], N_decimal_bits=self.Ndecimals, signed=True) for v, c in zip(self.values, self.coefs)]
        return np.sum(products) / 2**(11) # facteur des coefficients

    def eval(self, value):
        
        self.values[1:, :] = self.values[:-1, :]
        self.values[0] = float_to_array(value, N_bits=self.Nbits, N_decimal_bits=self.Ndecimals)
        output = self._calc_values()

        return output

    def eval_array(self, values):
        output = np.zeros_like(values)
        for i, v in enumerate(values):
            output[i] = self.eval(v)
        return output

    def reset(self):
        self.values[:,:] = 0
        

    




        


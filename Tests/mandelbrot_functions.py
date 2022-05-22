from decimal import Overflow
import numpy as np
from fixedpoint import FixedPoint

m = 3  # Integer bits (including sign bit)
n = 15  # decimals bits
range_real = (-2.2, 1)
range_imag = (-0.9375, 0.9375)
screen = (1024, 600)
MAX_ITER = 100
R = 2

real_values = list(np.linspace(range_real[0], range_real[1], screen[0]))
imag_values = list(np.linspace(range_imag[0], range_imag[1], screen[1]))

# def resize(x : FixedPoint):
#     print(x.qformat)
#     start =x.n-n
#     end = m + n-1
#     new = f"0b{x.bits[start:end]:0{m+n}b}"
#     print(f"[{start}:{end}] -> {new}")
#     return FixedPoint(new, m=m, n=n, signed=True, str_base=2)
def resize(x : FixedPoint):
    #x_str = str(x)
    x_str = f"{x.bits:0{x.m+x.n}b}"
    new = f"0b{x_str[x.m-m:x.m+n]}"
    #print(f"[{start}:{end}] -> {new}")
    return FixedPoint(new, m=m, n=n, signed=True, str_base=2)

def mult(A, B, m, n):
    out = A * B

    if isinstance(out, FixedPoint):
        out.resize(m,n)
    return out

def mandelbrot_iter(Cr, Ci, Zr_previous, Zi_previous, R, iterations_in, m=0, n=0, max_iter=100, done_in=False):
    is_fixed_point = isinstance(Cr, FixedPoint)

    if done_in:
        # Nothing to do
        done_out = 1
        Zr_next, Zi_next = Zr_previous, Zi_previous
        iterations_out = iterations_in
    else:
        # Calculate the new values
        Zrr = Zr_previous*Zr_previous
        Zii = Zi_previous*Zi_previous
        if is_fixed_point:
            Zrr = resize(Zrr)#.resize(m, n, overflow='wrap', alert='ignore')
            Zii = resize(Zii)#.resize(m, n, overflow='wrap', alert='ignore')

        Zr_temp = Zrr - Zii
        if is_fixed_point:
            Zr_temp = resize(Zr_temp)#.resize(m, n, overflow='wrap', alert='ignore')
        Zr_next = Zr_temp + Cr
        if is_fixed_point:
            Zr_next = resize(Zr_next)#.resize(m, n, overflow='wrap', alert='ignore')



        # Resize at each stage (to work the same way as VHDL)
        Zri = Zr_previous*Zi_previous
        if is_fixed_point:
            Zri = resize(Zri)#Zri.resize(m, n, overflow='wrap', alert='ignore')

        Zi_temp = Zri + Zri
        if is_fixed_point:
            Zi_temp = resize(Zi_temp)#.resize(m, n, overflow='wrap', alert='ignore')
        
        Zi_next = Zi_temp + Ci
        if is_fixed_point:
            Zi_next = resize(Zi_next)#.resize(m, n, overflow='wrap', alert='ignore')
        #Zi_next = Zi_temp


        iterations_out = iterations_in + 1

        Zr_next_square = Zr_next * Zr_next
        Zi_next_square = Zi_next * Zi_next
        R_square = R**2

        if Zr_next_square + Zi_next_square >= R_square:
            done_out = 1
        else:
            done_out = 0

    if is_fixed_point:
        Zr_next = resize(Zr_next)#.resize(m, n, overflow='wrap', alert='ignore')
        Zi_next = resize(Zi_next)#.resize(m, n, overflow='wrap', alert='ignore')

    return Zr_next, Zi_next, done_out, iterations_out


def mandelbrot_loop(Cr, Ci, R, m=0, n=0, max_iter=100):
    is_fixed_point = isinstance(Cr, FixedPoint)
    if is_fixed_point:
        Zr = FixedPoint(0, m=m, n=n, signed=True, str_base=2)
        Zi = FixedPoint(0, m=m, n=n, signed=True, str_base=2)
    else:
        Zr, Zi = 0, 0

    iterations = 0
    done = 0
    for _ in range(max_iter):
        Zr, Zi, done, iterations = mandelbrot_iter(Cr, Ci, Zr, Zi, R, iterations, m, n, max_iter, done)
        if done:
            break

    return iterations

import numpy as np
from numba import jit
from binary import number


def _mandelbrot_iteration(x):
    """
    Returns the next value of the mandelbrot iteration

    Parameters
    ----------
    x : complex
        Initial value
    
    Returns
    -------
    y : complex
        Output
    """


@jit(nopython=True)
def mandelbrot(x : complex, max_iter : int, r_stop : float):
    """
    Evaluate mandelbrot value at position x

    Parameters
    ----------
    x : complex
        starting position
    max_iter : int
        Maximum number of iterations
    r_stop : float
        Stopping radius
    
    Returns
    -------
    v : float
        last iteration value
    """
    iteration = lambda c,z : z**2 + c

    z = 0 + 0j
    for n in range(max_iter):
        z = iteration(x, z)
        if z.real**2 + z.imag**2 > r_stop**2:
            break
    return n


def mandelbrot_fixed(R : number, C : number, max_iter : int, r_stop : float, Nbits : int, Ndecimals : int):
    """
    Evaluate mandelbrot value at position x using fixed point numbers
    """
    iteration = lambda Cr, Ci, Zr, Zi : (Zr * Zr - Zi * Zi + Cr, 2 * Zr * Zi + Ci)


    Zr = number(Nbits, signed=True, Ndecimals=Ndecimals)
    Zi = Zr.__copy__()

    n = 0
    for i in range(max_iter):
        A = Zr * Zr
        print(A)
        print(A.Ndecimals)

        Zr, Zi = iteration(R, C, Zr, Zi)
        n += 1
        if Zr**2 + Zi**2 > r_stop**2:
            break
    return n




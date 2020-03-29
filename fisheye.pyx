###cython: boundscheck=False, wraparound=False, nonecheck=False, optimize.use_switch=True

"""
MIT License

Copyright (c) 2019 Yoann Berenguer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


"""

# NUMPY IS REQUIRED
try:
    import numpy
    from numpy import ndarray, zeros, empty, uint8, int32, float64, float32, dstack, full, ones,\
    asarray, ascontiguousarray
except ImportError:
    print("\n<numpy> library is missing on your system."
          "\nTry: \n   C:\\pip install numpy on a window command prompt.")
    raise SystemExit

# CYTHON IS REQUIRED
try:
    cimport cython
    from cython.parallel cimport prange
except ImportError:
    print("\n<cython> library is missing on your system."
          "\nTry: \n   C:\\pip install cython on a window command prompt.")
    raise SystemExit

cimport numpy as np

# OPENCV IS REQUIRED
try:
    import cv2
except ImportError:
    print("\n<cv2> library is missing on your system."
          "\nTry: \n   C:\\pip install opencv-python on a window command prompt.")
    raise SystemExit


# PYGAME IS REQUIRED
try:
    import pygame
    from pygame import Color, Surface, SRCALPHA, RLEACCEL, BufferProxy
    from pygame.surfarray import pixels3d, array_alpha, pixels_alpha, array3d
    from pygame.image import frombuffer

except ImportError:
    print("\n<Pygame> library is missing on your system."
          "\nTry: \n   C:\\pip install pygame on a window command prompt.")
    raise SystemExit


from libc.math cimport sin, sqrt, cos, atan2

DEF OPENMP = True

# num_threads – The num_threads argument indicates how many threads the team should consist of.
# If not given, OpenMP will decide how many threads to use.
# Typically this is the number of cores available on the machine. However,
# this may be controlled through the omp_set_num_threads() function,
# or through the OMP_NUM_THREADS environment variable.
if OPENMP == True:
    DEF THREAD_NUMBER = 8
else:
    DEF THREAD_NUMNER = 1

DEF SCHEDULE = 'static'

# ------------------------------------ INTERFACE ----------------------------------------------

def fish_eye24(image)->Surface:
    return fish_eye24_c(image)

def fish_eye32(image)->Surface:
    return fish_eye32_c(image)

# ------------------------------------ IMPLEMENTATION------------------------------------------

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
@cython.cdivision(True)
cdef fish_eye24_c(image):
    """
    Transform an image into a fish eye lens model.
    
    :param image: Surface (compatible only with 24-32 bit surface) 
    :return: Return a Surface without alpha channel, fish eye lens model.
    
    """
    assert isinstance(image, Surface), \
        "\nArgument image is not a pygame.Surface type, got %s " % type(image)

    try:
        array = pixels3d(image)
    except (pygame.error, ValueError):
        try:
            array = array3d(image)
        except:
            raise ValueError('\nInvalid pixel format.')

    cdef double w, h
    w, h = image.get_size()

    assert (w!=0 and h!=0),\
        'Incorrect image format (w>0, h>0) got (w:%s h:%s) ' % (w, h)

    cdef:
        unsigned char [:, :, :] rgb_array = array
        int y=0, x=0, v
        double ny, ny2, nx, nx2, r, theta, nxn, nyn, nr
        int x2, y2
        double s = w * h
        double c1 = 2 / h
        double c2 = 2 / w
        double w2 = w / 2
        double h2 = h / 2
        unsigned char [:, :, ::1] rgb_empty = zeros((int(h), int(w), 3), dtype=uint8)

    with nogil:
        for y in prange(<int>h, schedule=SCHEDULE, num_threads=THREAD_NUMBER, chunksize=8):
            ny = y * c1 - 1
            ny2 = ny * ny
            for x in range(<int>w):
                nx = x * c2 - 1.0
                nx2 = nx * nx
                r = sqrt(nx2 + ny2)
                if 0.0 <= r <= 1.0:
                    nr = (r + 1.0 - sqrt(1.0 - (nx2 + ny2))) * 0.5
                    if nr <= 1.0:
                        theta = atan2(ny, nx)
                        nxn = nr * cos(theta)
                        nyn = nr * sin(theta)
                        x2 = <int>(nxn * w2 + w2)
                        y2 = <int>(nyn * h2 + h2)
                        v = <int>(y2 * w + x2)
                        if 0 <= v < s:
                            rgb_empty[y, x, 0] = rgb_array[x2, y2, 0]
                            rgb_empty[y, x, 1] = rgb_array[x2, y2, 1]
                            rgb_empty[y, x, 2] = rgb_array[x2, y2, 2]

    return pygame.image.frombuffer(rgb_empty, (<int>w, <int>h), 'RGB')



@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
@cython.cdivision(True)
cdef fish_eye32_c(image):
    """
    Transform an image into a fish eye lens model (compatible 32-bit)
    
    :param image: Surface compatible 32-bit format with per-pixel 
    :return: Return a 32-bit Surface with alpha channel, fish eye lens model with per-pixel transparency
    
    """
    assert isinstance(image, Surface), \
        "\nArgument image is not a pygame.Surface type, got %s " % type(image)

    try:
        array = pixels3d(image)
        alpha = pixels_alpha(image)
    except (pygame.error, ValueError):
        raise ValueError('\nIncompatible pixel format.')

    cdef double w, h
    w, h = image.get_size()

    assert (w!=0 and h!=0),\
        'Incorrect image format (w>0, h>0) got (w:%s h:%s) ' % (w, h)

    cdef:
        unsigned char [:, :, :] rgb_array = array
        unsigned char [:, :] alpha_array = alpha
        int y=0, x=0, v
        double ny, ny2, nx, nx2, r, theta, nxn, nyn, nr
        int x2, y2
        double s = w * h
        double c1 = 2 / h
        double c2 = 2 / w
        double w2 = w / 2
        double h2 = h / 2
        unsigned char [:, :, ::1] rgb_empty = zeros((int(h), int(w), 4), dtype=uint8)
    with nogil:
        for y in prange(<int>h, schedule=SCHEDULE, num_threads=THREAD_NUMBER, chunksize=8):
            ny = y * c1 - 1
            ny2 = ny * ny
            for x in range(<int>w):
                nx = x * c2 - 1.0
                nx2 = nx * nx
                r = sqrt(nx2 + ny2)
                if 0.0 <= r <= 1.0:
                    nr = (r + 1.0 - sqrt(1.0 - (nx2 + ny2))) * 0.5
                    if nr <= 1.0:
                        theta = atan2(ny, nx)
                        nxn = nr * cos(theta)
                        nyn = nr * sin(theta)
                        x2 = <int>(nxn * w2 + w2)
                        y2 = <int>(nyn * h2 + h2)
                        v = <int>(y2 * w + x2)
                        if 0 <= v < s:
                            rgb_empty[y, x, 0] = rgb_array[x2, y2, 0]
                            rgb_empty[y, x, 1] = rgb_array[x2, y2, 1]
                            rgb_empty[y, x, 2] = rgb_array[x2, y2, 2]
                            rgb_empty[y, x, 3] = rgb_array[x2, y2, 3]

    return pygame.image.frombuffer(rgb_empty, (<int>w, <int>h), 'RGBA')

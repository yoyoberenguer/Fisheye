# Fisheye
### Fisheye lens algorithm using python and pygame

#### example:  

![alt text](https://github.com/yoyoberenguer/Fisheye/blob/master/example.PNG)

![alt text](https://github.com/yoyoberenguer/Fisheye/blob/master/lake-wallpapers.jpg)

![alt text](https://github.com/yoyoberenguer/Fisheye/blob/master/lake.jpg)

#### BELOW CYTHON CODE FOR FISHEYE ALGORITHM 
```
Compatible with 24 - 32bit format image.
The final image will be RGB type without per-pixel informations


@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
@cython.cdivision(True)
cpdef fish_eye_c(image):
    """ Fish eye algorithm """

    try:
        array = pygame.surfarray.pixels3d(image)
    except (pygame.error, ValueError):
        # unsupported colormasks for alpha reference array
        print('\nUnsupported colormasks for alpha reference array.')
        raise ValueError('\nMake sure the surface_ contains per-pixel alpha transparency values.')

    cdef:
        double w = image.get_size()[0]
        double h = image.get_size()[1]
    assert (w!=0 and h!=0), 'Incorrect image format (w>0, h>0) got (w:%s h:%s) ' % (w, h)

    cdef:
        cdef unsigned char [:, :, :] rgb_array = array
        int y=0, x=0, v
        double ny, ny2, nx, nx2, r, theta, nxn, nyn, nr
        int x2, y2
        double s = w * h
        double c1 = 2 / h
        double c2 = 2 / w
        double w2 = w / 2
        double h2 = h / 2
        unsigned char [:, :, ::1] rgb_empty = numpy.zeros((int(h), int(w), 3), dtype=numpy.uint8)
    with nogil:
        for y in prange(<int>h, schedule='static', chunksize=8):
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
                        if 0 <= v and v < s:
                            rgb_empty[y, x, 0], rgb_empty[y, x, 1], rgb_empty[y, x, 2] = rgb_array[x2, y2, 0],\
                            rgb_array[x2, y2, 1], rgb_array[x2, y2, 2]
    return pygame.image.frombuffer(rgb_empty, (<int>w, <int>h), 'RGB')

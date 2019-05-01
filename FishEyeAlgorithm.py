
import pygame
import math
def fish_eye(image: pygame.Surface):
    """ Fish eye algorithm """
    w, h = image.get_size()
    w2 = w / 2
    h2 = h / 2
    image_copy = pygame.Surface((w, h), flags=pygame.RLEACCEL).convert()
    for y in range(h):
        # Normalize every pixels along y axis
        # when y = 0 --> ny = -1
        # when y = h --> ny = +1
        ny = ((2 * y) / h) - 1
        # ny * ny pre calculated
        ny2 = ny ** 2
        for x in range(w):
            # Normalize every pixels along x axis
            # when x = 0 --> nx = -1
            # when x = w --> nx = +1
            nx = ((2 * x) / w) - 1
            # pre calculated nx * nx
            nx2 = nx ** 2

            # calculate distance from center (0, 0)
            r = math.sqrt(nx2 + ny2)

            # discard pixel if r below 0.0 or above 1.0
            if 0.0 <= r <= 1.0:

                nr = (r + 1 - math.sqrt(1 - r ** 2)) / 2
                if nr <= 1.0:

                    theta = math.atan2(ny, nx)
                    nxn = nr * math.cos(theta)
                    nyn = nr * math.sin(theta)
                    x2 = int(nxn * w2 + w2)
                    y2 = int(nyn * h2 + h2)

                    if 0 <= int(y2 * w + x2) < w * h:

                        pixel = image.get_at((x2, y2))
                        image_copy.set_at((x, y), pixel)

    return image_copy

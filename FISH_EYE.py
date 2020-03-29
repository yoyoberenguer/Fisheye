

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


from FISHEYE import fish_eye24, fish_eye32

import random

if __name__ == '__main__':

    w, h = 400, 400
    screen = pygame.display.set_mode((w * 2, h))

    background = pygame.image.load('back.png').convert()
    background.set_alpha(None)

    surface24 = pygame.image.load("EMARALD.jpg").convert()
    surface32 = pygame.image.load("EMARALD.jpg").convert_alpha()

    background = pygame.transform.smoothscale(background, (w * 2, h))
    surface24 = pygame.transform.smoothscale(surface24, (w, h))
    surface32 = pygame.transform.smoothscale(surface32, (w, h))

    i = 0
    fisheye_surface = fish_eye32(surface32)
    while 1:
        pygame.event.pump()
        keys = pygame.key.get_pressed()
        for event in pygame.event.get():
            if event.type == pygame.MOUSEMOTION:
                MOUSE_POS = event.pos

        if keys[pygame.K_F8]:
            pygame.image.save(screen, 'Screendump' + str(i) + '.png')
            
        if keys[pygame.K_ESCAPE]:
            break

        screen.fill((0, 0, 0))
        screen.blit(background, (0, 0))
        screen.blit(fisheye_surface, (0, 0))
        screen.blit(surface24, (w, 0))
        pygame.display.flip()

        i += 1
    pygame.quit()

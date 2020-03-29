# Fisheye
## Fisheye lens algorithm using python and pygame

![alt text](https://github.com/yoyoberenguer/Fisheye/blob/master/lake-wallpapers.jpg)

![alt text](https://github.com/yoyoberenguer/Fisheye/blob/master/lake.jpg)

## PROJECT:
```
This Library provide a selection of fast CYTHON methods for generating fisheye rendering.
The fisheye algorithms are compatible for both 24, 32-bit format textures.
```
## REQUIREMENT:
```
- python > 3.0
- numpy arrays
- pygame with SDL version 1.2 (SDL version 2 untested)
  Cython
- A compiler such visual studio, MSVC, CGYWIN setup correctly
  on your system.
  - a C compiler for windows (Visual Studio, MinGW etc) install on your system 
  and linked to your windows environment.
  Note that some adjustment might be needed once a compiler is install on your system, 
  refer to external documentation or tutorial in order to setup this process.
  e.g https://devblogs.microsoft.com/python/unable-to-find-vcvarsall-bat/
```
## MULTI - PROCESSING CAPABILITY
```
The flag OPENMP can be changed any time if you wish to use multiprocessing
or not (default True, using multi-processing).
Also you can change the number of threads needed with the flag THREAD_NUMBER (default 8 threads)
```
## BUILDING PROJECT:
```
In a command prompt and under the directory containing the source files
C:\>python setup_FishEye.py build_ext --inplace

If the compilation fail, refers to the requirement section and make sure cython 
and a C-compiler are correctly install on your system. 
```
## HOW TO:
```
Run the python file FISH_EYE.py for a demonstration.

32-bit Fish eye lens image can be obtain the following way in python 
------------------------------------------
import pygame
from FISHEYE import fish_eye24, fish_eye32
screen = pygame.display.set_mode((800, 600))
surface32 = pygame.image.load("EMARALD.jpg").convert_alpha()
surface32 = pygame.transform.smoothscale(surface32, (800, 600))
fisheye_surface = fish_eye32(surface32)
screen.blit(fisheye_surface, (0, 0))
pygame.display.flip()

------------------------------------------
```

![alt text](https://github.com/yoyoberenguer/Fisheye/blob/master/fishey32.PNG)

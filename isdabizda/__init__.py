import pygame
import sys

from pygame.locals import *

from isdabizda.grid import Grid, SMALL

pygame.init()
grid = Grid(SMALL)

## options
RES = grid.sizes[0] * grid.sizes[1]
RES = (RES,RES)
TITLE = "Isdabizda!"
FPS = 30


DISPLAY_SURF = pygame.display.set_mode(RES)
pygame.display.set_caption(TITLE)

clock = pygame.time.Clock()

# draw prettiness :D
grid.draw_grid(DISPLAY_SURF)
pygame.display.flip()

# loop
while True:
    for event in pygame.event.get():
        if event.type == QUIT:
            pygame.quit()
            sys.exit()
        elif event.type == MOUSEBUTTONDOWN:
            grid.draw_grid(DISPLAY_SURF)
            pygame.display.flip()
    clock.tick(FPS)
    print clock.get_fps()

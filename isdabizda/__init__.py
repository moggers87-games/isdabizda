import sys

from pygame.locals import *
import pygame
import pygame.event

from isdabizda.grid import Grid, SMALL

pygame.init()
grid = Grid(SMALL)

## options
RES = grid.sizes[0] * grid.sizes[1]
RES = (RES/2 ,RES/2)
TITLE = "Isdabizda!"
FPS = 15


DISPLAY_SURF = pygame.display.set_mode(RES)
pygame.display.set_caption(TITLE)

clock = pygame.time.Clock()

def update_display():
    grid.draw_grid(DISPLAY_SURF)
    pygame.display.flip()

update_display()

# loop
while True:
    for event in pygame.event.get():
        if event.type == QUIT:
            pygame.quit()
            sys.exit()
    pressed = pygame.key.get_pressed()
    if pressed[K_LEFT] == 1:
        grid.move_left()
        update_display()
    elif pressed[K_RIGHT] == 1:
        grid.move_right()
        update_display()
    elif pressed[K_DOWN] == 1:
        grid.move_down()
        update_display()
    elif pressed[K_UP] == 1:
        grid.rotate_block()
        update_display()
    elif pressed[K_q] == 1 or pressed[K_ESCAPE] == 1:
        pygame.event.post(pygame.event.Event(QUIT))
    clock.tick(FPS)

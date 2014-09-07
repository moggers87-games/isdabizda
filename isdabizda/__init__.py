import sys

from pygame.locals import *
import pygame
import pygame.event

from isdabizda.grid import Grid, SMALL, INCREASE_EVENT

pygame.init()
grid = Grid(SMALL)

## options
RES = grid.sizes[0] * grid.sizes[1]
RES = (RES/2 ,RES/2)
TITLE = "Isdabizda!"
FPS = 15
SKIP_TICKS = 2 # input cooldown
DOWN_TICKS = FPS # ticks before we drop down

DISPLAY_SURF = pygame.display.set_mode(RES)
ZOOMABLE_SURF = pygame.Surface(RES)
pygame.display.set_caption(TITLE)

clock = pygame.time.Clock()

def update_display():
    grid.draw_grid(ZOOMABLE_SURF)
    scaled_surface = pygame.transform.smoothscale(ZOOMABLE_SURF, RES)
    DISPLAY_SURF.blit(scaled_surface, (0,0))
    pygame.display.flip()

update_display()

skips_left = 0
ticks_left = DOWN_TICKS*2
# main loop
while True:
    #check for events, e.g. QUIT or INCREASE_EVENT
    for event in pygame.event.get():
        if event.type == QUIT:
            pygame.quit()
            sys.exit()
        elif event.type == INCREASE_EVENT:
            grid_size = ZOOMABLE_SURF.get_size()
            inrc_size = (8*grid.tile_size, 8*grid.tile_size)
            ZOOMABLE_SURF = pygame.transform.scale(ZOOMABLE_SURF, (grid_size[0]+inrc_size[0],grid_size[1]+inrc_size[1]))
            grid.extend(4,4)
            update_display()

    # auto dropping of blocks
    if ticks_left > 0:
        ticks_left = ticks_left - 1
    else:
        ticks_left = DOWN_TICKS
        grid.move_down()
        update_display()

    # keyboard stuff
    pressed = pygame.key.get_pressed()
    if skips_left > 0:
        skips_left = skips_left - 1
    elif pressed[K_LEFT] == 1:
        grid.move_left()
        update_display()
        skips_left = SKIP_TICKS
    elif pressed[K_RIGHT] == 1:
        grid.move_right()
        update_display()
        skips_left = SKIP_TICKS
    elif pressed[K_DOWN] == 1:
        grid.move_down()
        update_display()
        skips_left = SKIP_TICKS
    elif pressed[K_UP] == 1:
        grid.rotate_block()
        update_display()
        skips_left = SKIP_TICKS
    elif pressed[K_q] == 1 or pressed[K_ESCAPE] == 1:
        pygame.event.post(pygame.event.Event(QUIT))
    clock.tick(FPS)

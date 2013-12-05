from random import randint

from pygame import Rect, draw

SMALL = (32, 32)
MEDIUM = (128, 128)
LARGE = (512, 512)
TILE_SIZE = 16
class SquareException(Exception):
    pass

class Tile(Rect):
    """City tile, containing various data
    """
    def __init__(self, x, y, size):
        super(Tile, self).__init__(x*size, y*size, size, size)

    def __setattr__(self, attr, value):
        """Make sure we're square :)"""
        old_value = self.__getattribute__(attr)
        super(Tile, self).__setattr__(attr, value)
        if self.size[0] != self.size[1]:
            super(Tile, self).__setattr__(attr, old_value)
            raise SquareException("I need to be a square, reverting...")

class Grid(object):
    """Contains tiles"""
    def __init__(self, grid_size, tile_size=TILE_SIZE):
        self.sizes = (grid_size[0], tile_size)
        self._grid = []

        for x in xrange(grid_size[0]):
            column = []
            self._grid.append(column)
            for y in xrange(grid_size[1]):
                tile = Tile(x, y, tile_size)
                column.append(tile)

    def draw_grid(self, screen):
        for x in self._grid:
            for y in x:
                colour = (randint(0,255), randint(0,255), randint(0,255))
                draw.rect(screen, colour, y)

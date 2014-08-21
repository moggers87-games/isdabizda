from random import randint

from pygame import Rect, draw

from .entities import Falling

SMALL = (32, 32)
MEDIUM = (128, 128)
LARGE = (512, 512)
TILE_SIZE = 16

class SquareException(Exception):
    pass

class Tile(Rect):
    """City tile, containing various data
    """
    colour = (0, 0, 0)

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
        self._falling = None

        for x in xrange(grid_size[0]):
            column = []
            self._grid.append(column)
            for y in xrange(grid_size[1]):
                tile = Tile(x, y, tile_size)
                column.append(tile)

        self._falling = Falling()
        self._falling.rel_move((1, self.sizes[0]/2))

    def colourise(self, coord, colour):
        for x, y in coord:
            tile = self._grid[y][x]
            tile.colour = colour

    def drop_block(self):
        self.colourise(self._falling.coordinates, (0, 0, 0))
        self._falling.rel_move((1, 0))
        self.colourise(self._falling.coordinates, (255, 255, 255))

    def rotate_block(self):
        self.colourise(self._falling.coordinates, (0, 0, 0))
        self._falling.rotate()
        self.colourise(self._falling.coordinates, (255, 255, 255))

    def draw_grid(self, screen):
        for column in self._grid:
            for tile in column:
                draw.rect(screen, tile.colour, tile)

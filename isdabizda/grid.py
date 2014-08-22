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
    """A simple tile on the screen, has colour"""
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
    """The actual game grid

    Although we store tiles by row (and thus must fetch them by `y` and then
    `x`, all public interfaces accept coordinates in the traditional (x, y)
    format
    """
    def __init__(self, grid_size, tile_size=TILE_SIZE):
        self.sizes = (grid_size[0], tile_size)
        self._grid = []
        self._falling = None

        for y in xrange(grid_size[0]):
            row = []
            self._grid.append(row)
            for x in xrange(grid_size[1]):
                tile = Tile(x, y, tile_size)
                row.append(tile)

        self._falling = Falling()
        self._falling.rel_move((self.sizes[0]/2, 1))
        self.colourise(self._falling.coordinates, (255, 255, 255))

    def colourise(self, coords, colour):
        """Colour in a list of coordinates

        Raises an IndexError if the tiles will be outside the grid (except the
        top side, which is just silently ignored)
        """
        for x, y in coords:
            if y < 0:
                continue
            elif x < 0:
                raise IndexError("list index out of range")
            tile = self.get_tile(x, y)
            tile.colour = colour

    def get_tile(self, x, y):
        """Grab the tile at (x, y)"""
        return self._grid[y][x]

    def move_down(self):
        """Move the current block down"""
        self.colourise(self._falling.coordinates, (0, 0, 0))
        self._falling.rel_move((0, 1))
        self.colourise(self._falling.coordinates, (255, 255, 255))

    def move_left(self):
        """Move the current block left"""
        self.colourise(self._falling.coordinates, (0, 0, 0))
        self._falling.rel_move((-1, 0))
        self.colourise(self._falling.coordinates, (255, 255, 255))

    def move_right(self):
        """Move the current block right"""
        self.colourise(self._falling.coordinates, (0, 0, 0))
        self._falling.rel_move((1, 0))
        self.colourise(self._falling.coordinates, (255, 255, 255))

    def rotate_block(self):
        """Rotate the block clockwise"""
        self.colourise(self._falling.coordinates, (0, 0, 0))
        self._falling.rotate()
        self.colourise(self._falling.coordinates, (255, 255, 255))

    def draw_grid(self, screen):
        """Draw the grid on the given display surface

        Should be called any time the grid is updated
        """
        for row in self._grid:
            for tile in row:
                draw.rect(screen, tile.colour, tile)

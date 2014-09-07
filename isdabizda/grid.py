from random import randint
import copy

from pygame import Rect, draw

from .entities import Falling

SMALL = (32, 32)
MEDIUM = (128, 128)
LARGE = (512, 512)
TILE_SIZE = 16

class SquareException(Exception):
    pass

class CollisionException(Exception):
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
        self.sizes = copy.deepcopy(grid_size)
        self._grid = []
        self._falling = None

        for y in xrange(grid_size[1]):
            row = []
            self._grid.append(row)
            for x in xrange(grid_size[0]):
                tile = Tile(x, y, tile_size)
                row.append(tile)

        self.new_object()

    def new_object(self):
        self._falling = Falling()
        self._falling.rel_move((self.sizes[0]/2, 1))
        self.colourise(self._falling.coordinates, (255, 255, 255))

    def colourise(self, coords, colour):
        """Colour in a list of coordinates

        Raises an IndexError if the tiles will be outside the grid (except the
        top side, which is just silently ignored)
        """
        tiles_to_update = []
        for x, y in coords:
            if y < 0:
                continue
            elif x < 0:
                raise IndexError("list index out of range")
            tiles_to_update.append(self.get_tile(x, y))

        if colour != (0, 0, 0):
            detect_old_blocks = [tile.colour == (255, 255, 255) for tile in tiles_to_update]
            if True in detect_old_blocks:
                raise CollisionException("There's another block here")

        for tile in tiles_to_update:
            tile.colour = colour

    def get_tile(self, x, y):
        """Grab the tile at (x, y)"""
        return self._grid[y][x]

    def move_down(self):
        """Move the current block down"""
        old_coords = copy.copy(self._falling.coordinates)
        self.colourise(self._falling.coordinates, (0, 0, 0))
        self._falling.rel_move((0, 1))

        try:
            self.colourise(self._falling.coordinates, (255, 255, 255))
        except (IndexError, CollisionException):
            self.colourise(old_coords, (255, 255, 255))
            self.new_object()

    def move_left(self):
        """Move the current block left"""
        self.colourise(self._falling.coordinates, (0, 0, 0))
        self._falling.rel_move((-1, 0))

        try:
            self.colourise(self._falling.coordinates, (255, 255, 255))
        except (IndexError, CollisionException):
            self._falling.rel_move((1, 0))
            self.colourise(self._falling.coordinates, (255, 255, 255))

    def move_right(self):
        """Move the current block right"""
        self.colourise(self._falling.coordinates, (0, 0, 0))
        self._falling.rel_move((1, 0))

        try:
            self.colourise(self._falling.coordinates, (255, 255, 255))
        except (IndexError, CollisionException):
            self._falling.rel_move((-1, 0))
            self.colourise(self._falling.coordinates, (255, 255, 255))

    def rotate_block(self):
        """Rotate the block clockwise"""
        old_coords = copy.copy(self._falling.coordinates)
        self.colourise(self._falling.coordinates, (0, 0, 0))
        self._falling.rotate()

        try:
            self.colourise(self._falling.coordinates, (255, 255, 255))
        except IndexError:
            # work out which side we've hit
            # if we've hit the left or right side, bounce
            # if we're at the bottom, lock and create new object
            x, y = self._falling.coordinates[0]
            x_mid = self.sizes[0]/2
            y_mid = self.sizes[1]/2
            if x < x_mid:
                self._falling.rel_move((2, 0))
                self.colourise(self._falling.coordinates, (255, 255, 255))
            elif x > x_mid:
                self._falling.rel_move((-2, 0))
                self.colourise(self._falling.coordinates, (255, 255, 255))
        except CollisionException:
            self.colourise(old_coords, (255, 255, 255))
            self.new_object()

    def draw_grid(self, screen):
        """Draw the grid on the given display surface

        Should be called any time the grid is updated
        """
        for row in self._grid:
            for tile in row:
                draw.rect(screen, tile.colour, tile)

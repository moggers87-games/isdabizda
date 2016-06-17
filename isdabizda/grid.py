from random import randint
import copy

from pygame import Rect, draw
import pygame.event

from .entities import Falling

SIZES = {
    "small": (10, 22),
    "medium": (20, 44),
    "large": (40, 88),
}
TILE_SIZE = 16

INCREASE_EVENT = 29

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
    background = (0, 0, 0)

    def __init__(self, grid_size, tile_size=TILE_SIZE):
        self.sizes = copy.deepcopy(grid_size)
        self._grid = []
        self._falling = None
        self.tile_size = tile_size

        for y in xrange(grid_size[1]):
            row = []
            self._grid.append(row)
            for x in xrange(grid_size[0]):
                tile = Tile(x, y, tile_size)
                row.append(tile)

        self.new_object()

    def new_object(self):
        """Replace the current falling block"""
        self._falling = Falling()
        self._falling.rel_move((self.sizes[0]/2, 1))
        try:
            self.colourise(self._falling.coordinates, self._falling.colour)
        except CollisionException:
            pygame.event.post(pygame.event.Event(INCREASE_EVENT))

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

        if colour != self.background:
            detect_old_blocks = [tile.colour != self.background for tile in tiles_to_update]
            if True in detect_old_blocks:
                raise CollisionException("There's another block here")

        for tile in tiles_to_update:
            tile.colour = colour

    def detect_tetris(self, coords):
        """Detect if we have any full rows

        Return True if a line was detected
        """
        out = False
        rows = set([pair[1] for pair in coords])
        for row in rows:
            tiles = [tile.colour != self.background for tile in self._grid[row]]
            if False in tiles:
                continue
            else:
                out = True
                pygame.event.post(pygame.event.Event(INCREASE_EVENT))

        return out

    def extend(self, x_incr=0, y_incr=0):
        """Extend the grid, there is no losing"""
        old_size = copy.copy(self.sizes)
        self.sizes = (self.sizes[0] + 2 * x_incr, self.sizes[1] + 2 * y_incr)
        new_grid = []

        for y in xrange(self.sizes[1]):
            row = []
            new_grid.append(row)
            for x in xrange(self.sizes[0]):
                tile = Tile(x, y, self.tile_size)
                row.append(tile)

        for y in xrange(old_size[1]):
            for x in xrange(old_size[0]):
                old_tile = self.get_tile(x, y)
                tile = new_grid[y+(2*y_incr)][x+x_incr]
                tile.colour = old_tile.colour

        self._grid = new_grid

        self.new_object()

    def get_tile(self, x, y):
        """Grab the tile at (x, y)"""
        if x < 0 or y < 0:
            raise IndexError("list index out of range")
        return self._grid[y][x]

    def move_down(self):
        """Move the current block down"""
        old_coords = copy.copy(self._falling.coordinates)
        self.colourise(self._falling.coordinates, self.background)
        self._falling.rel_move((0, 1))

        try:
            self.colourise(self._falling.coordinates, self._falling.colour)
        except (IndexError, CollisionException):
            self.colourise(old_coords, self._falling.colour)
            if not self.detect_tetris(old_coords):
                self.new_object()

    def move_left(self):
        """Move the current block left"""
        self.colourise(self._falling.coordinates, self.background)
        self._falling.rel_move((-1, 0))

        try:
            self.colourise(self._falling.coordinates, self._falling.colour)
        except (IndexError, CollisionException):
            self._falling.rel_move((1, 0))
            self.colourise(self._falling.coordinates, self._falling.colour)

    def move_right(self):
        """Move the current block right"""
        self.colourise(self._falling.coordinates, self.background)
        self._falling.rel_move((1, 0))

        try:
            self.colourise(self._falling.coordinates, self._falling.colour)
        except (IndexError, CollisionException):
            self._falling.rel_move((-1, 0))
            self.colourise(self._falling.coordinates, self._falling.colour)

    def rotate_block(self):
        """Rotate the block clockwise"""
        old_coords = copy.copy(self._falling.coordinates)
        self.colourise(self._falling.coordinates, self.background)
        self._falling.rotate()

        try:
            self.colourise(self._falling.coordinates, self._falling.colour)
        except IndexError:
            # work out which side we've hit
            # if we've hit the left or right side, bounce
            # if we're at the bottom, lock and create new object
            x, y = self._falling.coordinates[0]
            x_mid = self.sizes[0]/2
            y_mid = self.sizes[1]/2
            if x < x_mid:
                self._falling.rel_move((2, 0))
                self.colourise(self._falling.coordinates, self._falling.colour)
            elif x > x_mid:
                self._falling.rel_move((-2, 0))
                self.colourise(self._falling.coordinates, self._falling.colour)
        except CollisionException:
            self.colourise(old_coords, self._falling.colour)
            self.new_object()

    def draw_grid(self, screen):
        """Draw the grid on the given display surface

        Should be called any time the grid is updated
        """
        for row in self._grid:
            for tile in row:
                draw.rect(screen, tile.colour, tile)

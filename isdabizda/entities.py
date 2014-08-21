import copy
import random

TYPES = (
    [(0,0), (0,1), (0,2), (0,-1)], # I
    [(0,0), (1,0), (-1,0), (0,1)], # T
    [(0,0), (-1,0), (0,1), (1,1)], # Z
    [(0,0), (1,0), (0,1), (-1,1)], # S
    [(0,0), (-1,0), (0,1), (0,2)], # J
    [(0,0), (1,0), (0,1), (0,2)], # L
    [(0,0), (0,1), (1,0), (1,1)], # O
    )

class Falling(object):
    """A falling block"""
    def __init__(self):
        self.coordinates = copy.deepcopy(random.choice(TYPES))

    def __repr__(self):
        return "<{0}.{1} object at {2}>".format(
                self.__class__.__module__,
                self.__class__.__name__,
                self.coordinates,
                )

    def rel_move(self, vector):
        """Move block by (x,y) tiles"""
        for i, coord in enumerate(self.coordinates):
            x = coord[0] + vector[0]
            y = coord[1] + vector[1]
            self.coordinates[i] = (x, y)

    def rotate(self):
        """Rotate 90 deg anti-clockwise"""
        zero = self.coordinates[0]
        for i, coord in enumerate(self.coordinates):
            # move back to origin
            x_old = coord[0] - zero[0]
            y_old = coord[1] - zero[1]
            # rotate
            x = -y_old
            y = x_old
            # move back to original position
            x = x + zero[0]
            y = y + zero[1]
            self.coordinates[i] = (x, y)

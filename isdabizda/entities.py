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
        """Move block by (y, x) tiles"""
        for i, coord in enumerate(self.coordinates):
            y = coord[0] + vector[0]
            x = coord[1] + vector[1]
            self.coordinates[i] = (y, x)

    def rotate(self, clockwise=True):
        """Rotate 90 degrees of arc

        If `clockwise=True`, rotate clockwise, if `False` then rotate
        counter-clockwise.
        """
        if clockwise:
            rot_vector = (1,-1)
        else:
            rot_vector = (-1,1)
        zero = self.coordinates[0]
        for i, coord in enumerate(self.coordinates):
            # move back to origin
            y_old = coord[0] - zero[0]
            x_old = coord[1] - zero[1]

            # rotate
            y = x_old * rot_vector[1]
            x = y_old * rot_vector[0]

            # move back to original position
            y = y + zero[0]
            x = x + zero[1]
            self.coordinates[i] = (y, x)

import numpy as np


class Plant:
    """Plant class representing food for herbivores"""
    
    def __init__(self, location):
        self.type = "plant"
        self.eaten = False
        self.location = np.array(location)
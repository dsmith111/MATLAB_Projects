from creature import Creature


class Predator(Creature):
    """Creature which hunts other creatures"""
    
    def __init__(self, location):
        super().__init__(location)
        self.type = "predator"
        self.enemy_type = "herbivore"
        self.food_type = "carcass"
        self.regen = 0.05
        self.damage = 0.1
        self.stress_thresh = 0.85
        self.aggressive_placid = 0.80
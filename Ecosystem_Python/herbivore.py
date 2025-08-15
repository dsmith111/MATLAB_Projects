from creature import Creature


class Herbivore(Creature):
    """Creature which only eats plants"""
    
    def __init__(self, location):
        super().__init__(location)
        self.type = "herbivore"
        self.enemy_type = "predator"
        self.food_type = "plant"
        self.regen = 0.05
        self.damage = 0.1
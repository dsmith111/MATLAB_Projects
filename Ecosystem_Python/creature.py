import numpy as np
from typing import List, Tuple, Optional, Dict, Any
import random


class Creature:
    """Base creature class to be used for predators and herbivores"""
    
    def __init__(self, location: List[int]):
        # Basic properties
        self.type = "none"
        self.food_type = "none"
        self.enemy_type = "none"
        self.action = "none"
        
        # Status Levels
        self.stress_level = 0.0
        self.hunger_level = 0.5
        self.health_level = 1.0
        self.age = 0
        self.mature = 15
        self.sight_range = 3
        self.times_reproduced = 0
        self.max_reproduce = 3
        self.regen = 0.05
        self.damage = 0.1
        self.nourish = 0.1
        self.alive = True
        
        # Weights
        self.stress_weight = 0.5
        self.hunger_weight = 0.5
        self.health_weight = 0.5
        self.health_thresh = 0.5
        self.hunger_thresh = 0.5
        self.stress_thresh = 0.5
        
        # Personality Makeup (1 -> 0, first term -> second term)
        self.aggressive_placid = 0.5
        self.fear_brave = 0.5
        self.social_isolationist = 0.5
        
        # Location and nearby objects
        self.location = np.array(location)
        self.friendlies_close = []
        self.enemies_close = []
        self.food_close = []
        self.friend_distances = []
        self.enemy_distances = []
        self.food_distances = []
        self.other_close = []
        self.closest_enemy = None
        self.closest_friend = None
        self.closest_food = None
        self.enemy_loc_index = 0
        self.friend_loc_index = 0
        self.food_loc_index = 0
        self.friend_location = []
        self.enemy_location = []
        self.food_location = []
        self.friendlies_indices = []
        self.enemies_indices = []
        self.food_indices = []
        
        # List of unformatted objects
        self.entities_close = []
        self.entities_dist = []
        self.child_location = []
        self.map_size = 0
    
    def process_sight(self, object_list: List['Creature'], map_size: int) -> 'Creature':
        """Process sight to identify nearby objects"""
        self.map_size = map_size
        
        # Reset sight data
        self.friendlies_close = []
        self.friendlies_indices = []
        self.enemies_close = []
        self.enemies_indices = []
        self.food_close = []
        self.food_indices = []
        
        # Get all object locations
        object_locations = np.array([obj.location for obj in object_list])
        
        # Calculate distances to all objects
        distances = np.linalg.norm(object_locations - self.location, axis=1)
        
        # Find objects within sight range
        close_indices = np.where(distances <= self.sight_range)[0]
        close_objects = [object_list[i] for i in close_indices]
        self.entities_close = close_objects
        self.entities_dist = distances[close_indices]
        
        # Categorize nearby objects
        for i, obj in enumerate(close_objects):
            global_index = close_indices[i]
            
            if obj.type == self.type:
                self.friendlies_close.append(obj)
                self.friendlies_indices.append(global_index)
            elif obj.type == self.food_type:
                self.food_close.append(obj)
                self.food_indices.append(global_index)
            elif obj.type == self.enemy_type:
                self.enemies_close.append(obj)
                self.enemies_indices.append(global_index)
            else:
                self.other_close.append(obj)
        
        # Calculate distances to each category
        self._calculate_category_distances()
        
        return self
    
    def _calculate_category_distances(self):
        """Calculate distances to enemies, friends, and food"""
        # Enemy distances
        self.enemy_distances = []
        if self.enemies_close:
            self.enemy_distances = [np.linalg.norm(enemy.location - self.location) 
                                  for enemy in self.enemies_close]
            min_enemy_idx = np.argmin(self.enemy_distances)
            self.closest_enemy = self.enemies_close[min_enemy_idx]
            self.enemy_location = self.closest_enemy.location
            self.enemy_loc_index = self.enemies_indices[min_enemy_idx]
        
        # Friend distances
        self.friend_distances = []
        if self.friendlies_close:
            self.friend_distances = [np.linalg.norm(friend.location - self.location) 
                                   for friend in self.friendlies_close]
            min_friend_idx = np.argmin(self.friend_distances)
            self.closest_friend = self.friendlies_close[min_friend_idx]
            self.friend_location = self.closest_friend.location
            self.friend_loc_index = self.friendlies_indices[min_friend_idx]
        
        # Food distances
        self.food_distances = []
        if self.food_close:
            self.food_distances = [np.linalg.norm(food.location - self.location) 
                                 for food in self.food_close]
            min_food_idx = np.argmin(self.food_distances)
            self.closest_food = self.food_close[min_food_idx]
            self.food_location = self.closest_food.location
            self.food_loc_index = self.food_indices[min_food_idx]
    
    def process_stress(self) -> 'Creature':
        """Calculate stress level based on environment"""
        stress_base = 0.25
        amount_enemies = len(self.enemies_close)
        amount_friends = len(self.friendlies_close)
        
        # Stress level due to threat
        threat_weight = amount_enemies / ((self.sight_range * 2) ** 2)
        threat_stress = threat_weight * stress_base
        
        # Stress level due to friends
        friend_weight = amount_friends / ((self.sight_range * 2) ** 2)
        friend_stress = (friend_weight * stress_base + 
                        self.social_isolationist * (stress_base / 2))
        friend_stress = min(friend_stress, stress_base)
        
        # Stress level due to food
        food_stress = (self.hunger_level * (stress_base / 2) + 
                      self.hunger_weight * (stress_base / 2))
        
        # Stress level due to health
        health_stress = (self.health_level * (stress_base / 2) + 
                        self.health_weight * (stress_base / 2))
        
        # Calculate total stress
        self.stress_level = (threat_stress + food_stress + health_stress) - friend_stress
        self.stress_level = max(0, min(1, self.stress_level))
        
        return self
    
    def process_thought(self) -> 'Creature':
        """Process decision making based on current state"""
        self.health_thresh = self.health_weight * self.health_level
        self.hunger_thresh = self.hunger_weight * self.hunger_level
        self.stress_thresh = self.stress_weight * self.stress_level
        
        is_mature = self.age > self.mature
        is_full = self.hunger_level > self.hunger_thresh
        is_healthy = self.health_level > self.health_thresh
        is_stressed = self.stress_level > self.stress_thresh
        enemies_near = len(self.enemies_close) > 0
        friends_near = len(self.friendlies_close) > 0
        food_near = len(self.food_close) > 0
        out_numbered = len(self.enemies_close) > (len(self.friendlies_close) + 1)
        
        # Decision making hierarchy
        if (is_mature and is_healthy and is_full and not is_stressed and 
            not enemies_near and friends_near):
            self.action = "rep"
        elif not is_healthy and is_full:
            self.action = "rest"
        elif (not is_full and food_near and 
              (not self.enemy_distances or min(self.enemy_distances) > 2)):
            self.action = "eat"
        elif enemies_near and not is_stressed and is_healthy:
            self.action = "attack"
        elif enemies_near and (is_stressed or not is_healthy or out_numbered):
            self.action = "flee"
        else:
            self.action = "wander"
        
        return self
    
    def process_action(self) -> Tuple['Creature', str]:
        """Execute the chosen action"""
        recent_action = "nothing"
        
        if self.action == "rep":
            distance = self._nearest_creature_distance(self.type)
            if distance == 1:
                o_location = self._find_empty()
                if o_location is not None:
                    self.child_location = o_location
                    recent_action = "rep"
                else:
                    self.child_location = None
            elif distance > 1 and self.closest_friend is not None:
                o_location = self._find_near_empty(self.closest_friend.location)
                if o_location is not None:
                    self.location = o_location
        
        elif self.action == "rest":
            if self.health_level != 1:
                self.regenerate()
        
        elif self.action == "eat":
            distance = self._nearest_creature_distance(self.food_type)
            if distance == 1:
                recent_action = "eat"
                self.hunger_level = min(1.0, self.hunger_level + self.nourish)
            elif distance > 1 and self.closest_food is not None:
                o_location = self._find_near_empty(self.closest_food.location)
                if o_location is not None:
                    self.location = o_location
        
        elif self.action == "attack":
            distance = self._nearest_creature_distance(self.enemy_type)
            if distance == 1:
                recent_action = "attack"
            elif distance > 1 and self.closest_enemy is not None:
                o_location = self._find_near_empty(self.closest_enemy.location)
                if o_location is not None:
                    self.location = o_location
        
        elif self.action == "flee":
            if self.closest_enemy is not None:
                o_location = self._find_near_empty(self.closest_enemy.location, "flee")
                if o_location is not None:
                    self.location = o_location
        
        elif self.action == "wander":
            o_location = self._find_empty(random_sel=True)
            if o_location is not None:
                self.location = o_location
        
        return self, recent_action
    
    def regenerate(self) -> 'Creature':
        """Regenerate health"""
        self.health_level = min(1.0, self.health_level + self.regen)
        return self
    
    def hurt(self) -> 'Creature':
        """Take damage"""
        self.health_level = max(0.0, self.health_level - self.damage)
        return self
    
    def _nearest_creature_distance(self, creature_type: str) -> float:
        """Find distance to nearest creature of specified type"""
        min_distance = float('inf')
        
        for obj in self.entities_close:
            if obj.type == creature_type:
                distance = np.linalg.norm(obj.location - self.location)
                min_distance = min(min_distance, distance)
        
        return 0 if min_distance == float('inf') else min_distance
    
    def _find_empty(self, iteration_skip: int = 0, random_sel: bool = False) -> Optional[np.ndarray]:
        """Find nearest empty tile"""
        locations_check = []
        
        # Generate adjacent locations
        for i in range(-1, 2):
            for k in range(-1, 2):
                if i == 0 and k == 0:
                    continue
                
                new_y = self.location[0] + i
                new_x = self.location[1] + k
                
                if (new_y > self.map_size or new_x > self.map_size or 
                    new_y < 1 or new_x < 1):
                    continue
                
                locations_check.append([new_y, new_x])
        
        if random_sel and locations_check:
            random.shuffle(locations_check)
        
        # Check each location for emptiness
        for location in locations_check:
            is_empty = True
            for obj in self.entities_close:
                if np.array_equal(obj.location, location):
                    is_empty = False
                    break
            
            if is_empty:
                if iteration_skip > 0:
                    iteration_skip -= 1
                    continue
                return np.array(location)
        
        return None
    
    def _find_near_empty(self, poi_location: np.ndarray, pursuit: str = "pursue") -> Optional[np.ndarray]:
        """Find closest movement position relative to point of interest"""
        best_location = self.location.copy()
        current_distance = np.linalg.norm(self.location - poi_location)
        
        for i in range(8):
            checked_location = self._find_empty(iteration_skip=i)
            
            if checked_location is None:
                continue
            
            checked_distance = np.linalg.norm(checked_location - poi_location)
            
            if pursuit == "pursue":
                if checked_distance < current_distance and checked_distance != 0:
                    best_location = checked_location
                    current_distance = checked_distance
            elif pursuit == "flee":
                if checked_distance > current_distance:
                    best_location = checked_location
                    current_distance = checked_distance
        
        return best_location if not np.array_equal(best_location, self.location) else None
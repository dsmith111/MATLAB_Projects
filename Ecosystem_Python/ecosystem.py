import numpy as np
import matplotlib.pyplot as plt
import time
import random
from herbivore import Herbivore
from predator import Predator
from plant import Plant
from world_manager import WorldManager


def main():
    """Main ecosystem simulation"""
    # Size of world
    world_size = 60
    
    # Number of creatures
    amount_herb = round(world_size / 3)
    amount_pred = round(world_size / 8)
    amount_plant = round(world_size / 2)
    
    total_objects = amount_herb + amount_pred + amount_plant
    
    # Create randomized list of locations to assign to objects
    randomized_locations = []
    used_locations = set()
    
    for i in range(total_objects):
        while True:
            r = random.randint(1, world_size - 1)
            c = random.randint(1, world_size - 1)
            location = (r, c)
            
            if location not in used_locations:
                used_locations.add(location)
                randomized_locations.append([r, c])
                break
    
    # Initialize creatures
    object_list = []
    
    for i in range(total_objects):
        if i < amount_herb:
            obj = Herbivore(randomized_locations[i])
        elif i < amount_herb + amount_pred:
            obj = Predator(randomized_locations[i])
        else:
            obj = Plant(randomized_locations[i])
        
        object_list.append(obj)
    
    # Set up matplotlib for real-time plotting
    plt.ion()
    plt.figure(figsize=(10, 8))
    
    print(f"Starting ecosystem simulation with:")
    print(f"Herbivores: {amount_herb}")
    print(f"Predators: {amount_pred}")
    print(f"Plants: {amount_plant}")
    print(f"World size: {world_size}x{world_size}")
    print("Press Ctrl+C to stop the simulation\n")
    
    # Run simulation
    try:
        for iteration in range(100):
            start_time = time.time()
            
            # Update Objects
            for k in range(len(object_list)):
                focused_object = object_list[k]
                
                if focused_object.type == "plant":
                    continue
                
                # Process creature behavior
                focused_object.process_sight(object_list, world_size)
                focused_object.process_stress()
                focused_object.process_thought()
                focused_object, action = focused_object.process_action()
                
                # Handle special actions
                if action == "rep":
                    if focused_object.type == "herbivore":
                        child = Herbivore(focused_object.child_location)
                    else:  # predator
                        child = Predator(focused_object.child_location)
                    object_list.append(child)
                
                elif action == "attack":
                    if focused_object.enemy_loc_index < len(object_list):
                        enemy = object_list[focused_object.enemy_loc_index]
                        enemy.hurt()
                        object_list[focused_object.enemy_loc_index] = enemy
                
                elif action == "eat":
                    if focused_object.food_loc_index < len(object_list):
                        food = object_list[focused_object.food_loc_index]
                        if hasattr(food, 'eaten'):
                            food.eaten = True
                            object_list[focused_object.food_loc_index] = food
                
                object_list[k] = focused_object
            
            # Update world state
            object_list = WorldManager.update_list(object_list)
            
            # Draw the map
            WorldManager.draw_map(world_size, object_list)
            
            # Calculate and display statistics
            herbivore_count = sum(1 for obj in object_list if obj.type == "herbivore")
            predator_count = sum(1 for obj in object_list if obj.type == "predator")
            plant_count = sum(1 for obj in object_list if obj.type == "plant")
            
            elapsed_time = time.time() - start_time
            
            print(f"Iteration {iteration + 1}: H={herbivore_count}, P={predator_count}, "
                  f"Pl={plant_count}, Time={elapsed_time:.3f}s")
            
            # Check if ecosystem has collapsed
            if herbivore_count == 0 and predator_count == 0:
                print("Ecosystem has collapsed - no creatures remain!")
                break
            
            plt.pause(0.1)
    
    except KeyboardInterrupt:
        print("\nSimulation stopped by user")
    
    except Exception as e:
        print(f"Error during simulation: {e}")
        import traceback
        traceback.print_exc()
    
    finally:
        print("Simulation ended")
        plt.ioff()
        plt.show()


if __name__ == "__main__":
    main()
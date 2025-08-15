#!/usr/bin/env python3
"""
Non-interactive version of ecosystem simulation for testing/headless environments
"""

import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend

import numpy as np
import matplotlib.pyplot as plt
import time
import random
from herbivore import Herbivore
from predator import Predator
from plant import Plant
from world_manager import WorldManager


def run_simulation(iterations=10, save_plots=True, world_size=60):
    """Run ecosystem simulation in non-interactive mode"""
    
    # Number of creatures
    amount_herb = round(world_size / 3)
    amount_pred = round(world_size / 8)
    amount_plant = round(world_size / 2)
    
    total_objects = amount_herb + amount_pred + amount_plant
    
    # Create randomized list of locations to assign to objects
    randomized_locations = []
    used_locations = set()
    
    for i in range(total_objects):
        attempts = 0
        while attempts < 100:  # Prevent infinite loop
            r = random.randint(1, world_size - 1)
            c = random.randint(1, world_size - 1)
            location = (r, c)
            
            if location not in used_locations:
                used_locations.add(location)
                randomized_locations.append([r, c])
                break
            attempts += 1
        
        if attempts >= 100:
            # Fallback if we can't find unique locations
            randomized_locations.append([random.randint(1, world_size - 1), 
                                       random.randint(1, world_size - 1)])
    
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
    
    print(f"Starting ecosystem simulation with:")
    print(f"Herbivores: {amount_herb}")
    print(f"Predators: {amount_pred}")
    print(f"Plants: {amount_plant}")
    print(f"World size: {world_size}x{world_size}")
    print(f"Running {iterations} iterations...\n")
    
    # Track statistics
    stats = []
    
    # Run simulation
    for iteration in range(iterations):
        start_time = time.time()
        
        # Update Objects
        objects_to_update = list(range(len(object_list)))
        for k in objects_to_update:
            if k >= len(object_list):
                continue
                
            focused_object = object_list[k]
            
            if focused_object.type == "plant":
                continue
            
            # Process creature behavior
            try:
                focused_object.process_sight(object_list, world_size)
                focused_object.process_stress()
                focused_object.process_thought()
                focused_object, action = focused_object.process_action()
                
                # Handle special actions
                if action == "rep":
                    if focused_object.child_location is not None:
                        if focused_object.type == "herbivore":
                            child = Herbivore(focused_object.child_location)
                        else:  # predator
                            child = Predator(focused_object.child_location)
                        object_list.append(child)
                
                elif action == "attack":
                    if (focused_object.enemy_loc_index < len(object_list) and 
                        focused_object.enemy_loc_index >= 0):
                        enemy = object_list[focused_object.enemy_loc_index]
                        if hasattr(enemy, 'hurt'):
                            enemy.hurt()
                
                elif action == "eat":
                    if (focused_object.food_loc_index < len(object_list) and 
                        focused_object.food_loc_index >= 0):
                        food = object_list[focused_object.food_loc_index]
                        if hasattr(food, 'eaten'):
                            food.eaten = True
                
                object_list[k] = focused_object
                
            except Exception as e:
                print(f"Error processing creature {k}: {e}")
                continue
        
        # Update world state
        object_list = WorldManager.update_list(object_list)
        
        # Calculate and display statistics
        herbivore_count = sum(1 for obj in object_list if obj.type == "herbivore")
        predator_count = sum(1 for obj in object_list if obj.type == "predator")
        plant_count = sum(1 for obj in object_list if obj.type == "plant")
        
        elapsed_time = time.time() - start_time
        
        stats.append({
            'iteration': iteration + 1,
            'herbivores': herbivore_count,
            'predators': predator_count,
            'plants': plant_count,
            'time': elapsed_time
        })
        
        print(f"Iteration {iteration + 1}: H={herbivore_count}, P={predator_count}, "
              f"Pl={plant_count}, Time={elapsed_time:.3f}s")
        
        # Save plot every few iterations
        if save_plots and (iteration % 5 == 0 or iteration == iterations - 1):
            plt.figure(figsize=(10, 8))
            
            # Separate objects by type for plotting
            herbivores = []
            predators = []
            plants = []
            
            for obj in object_list:
                if obj.type == "herbivore":
                    herbivores.append(obj.location)
                elif obj.type == "predator":
                    predators.append(obj.location)
                elif obj.type == "plant":
                    plants.append(obj.location)
            
            # Plot each type with different markers and colors
            if herbivores:
                herbivores = np.array(herbivores)
                plt.scatter(herbivores[:, 1], herbivores[:, 0], 
                           c='blue', marker='*', s=50, label='Herbivores')
            
            if predators:
                predators = np.array(predators)
                plt.scatter(predators[:, 1], predators[:, 0], 
                           c='red', marker='x', s=50, label='Predators')
            
            if plants:
                plants = np.array(plants)
                plt.scatter(plants[:, 1], plants[:, 0], 
                           c='green', marker='^', s=30, label='Plants')
            
            plt.xlim(1, world_size)
            plt.ylim(1, world_size)
            plt.legend()
            plt.title(f'Ecosystem Simulation - Iteration {iteration + 1}')
            plt.xlabel('X Position')
            plt.ylabel('Y Position')
            plt.grid(True, alpha=0.3)
            
            filename = f'ecosystem_iteration_{iteration + 1:03d}.png'
            plt.savefig(filename, dpi=150, bbox_inches='tight')
            plt.close()
            print(f"  Saved plot: {filename}")
        
        # Check if ecosystem has collapsed
        if herbivore_count == 0 and predator_count == 0:
            print("Ecosystem has collapsed - no creatures remain!")
            break
    
    print(f"\nSimulation completed after {len(stats)} iterations")
    return stats


if __name__ == "__main__":
    stats = run_simulation(iterations=10, save_plots=True)
    print("\n✅ Ecosystem simulation completed successfully!")
#!/usr/bin/env python3
"""
Test script for the ecosystem simulation.
Runs a short simulation to verify everything works correctly.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from herbivore import Herbivore
from predator import Predator
from plant import Plant
from world_manager import WorldManager


def test_basic_functionality():
    """Test basic functionality of all classes"""
    print("Testing basic functionality...")
    
    # Test creating creatures
    herbivore = Herbivore([10, 10])
    predator = Predator([15, 15])
    plant = Plant([5, 5])
    
    print(f"Created herbivore at {herbivore.location}, type: {herbivore.type}")
    print(f"Created predator at {predator.location}, type: {predator.type}")
    print(f"Created plant at {plant.location}, type: {plant.type}")
    
    # Test world management
    object_list = [herbivore, predator, plant]
    print(f"Initial object count: {len(object_list)}")
    
    # Test sight processing
    herbivore.process_sight(object_list, 60)
    print(f"Herbivore sees {len(herbivore.entities_close)} entities")
    print(f"Herbivore sees {len(herbivore.enemies_close)} enemies")
    print(f"Herbivore sees {len(herbivore.food_close)} food sources")
    
    # Test decision making
    herbivore.process_stress()
    herbivore.process_thought()
    print(f"Herbivore stress level: {herbivore.stress_level:.3f}")
    print(f"Herbivore action: {herbivore.action}")
    
    # Test action processing
    herbivore, action = herbivore.process_action()
    print(f"Herbivore performed action: {action}")
    
    print("Basic functionality test completed successfully!")
    return True


def test_mini_simulation():
    """Run a mini simulation for a few iterations"""
    print("\nRunning mini simulation...")
    
    # Create a small ecosystem
    object_list = []
    
    # Add some creatures
    for i in range(3):
        herbivore = Herbivore([10 + i, 10 + i])
        object_list.append(herbivore)
    
    for i in range(1):
        predator = Predator([20, 20])
        object_list.append(predator)
    
    for i in range(5):
        plant = Plant([5 + i*2, 5 + i*2])
        object_list.append(plant)
    
    print(f"Starting with {len(object_list)} objects")
    
    # Run a few iterations
    for iteration in range(3):
        print(f"\nIteration {iteration + 1}:")
        
        # Process each creature
        for k in range(len(object_list)):
            obj = object_list[k]
            
            if obj.type == "plant":
                continue
            
            # Process creature behavior
            obj.process_sight(object_list, 60)
            obj.process_stress()
            obj.process_thought()
            obj, action = obj.process_action()
            
            print(f"  {obj.type} at {obj.location} performed: {action}")
            
            object_list[k] = obj
        
        # Update world
        object_list = WorldManager.update_list(object_list)
        
        # Count entities
        herbivore_count = sum(1 for obj in object_list if obj.type == "herbivore")
        predator_count = sum(1 for obj in object_list if obj.type == "predator")
        plant_count = sum(1 for obj in object_list if obj.type == "plant")
        
        print(f"  Population: H={herbivore_count}, P={predator_count}, Pl={plant_count}")
    
    print("Mini simulation completed successfully!")
    return True


if __name__ == "__main__":
    try:
        success = test_basic_functionality()
        if success:
            success = test_mini_simulation()
        
        if success:
            print("\n✅ All tests passed! The ecosystem is ready to run.")
            print("Run 'python ecosystem.py' to start the full simulation.")
        else:
            print("\n❌ Tests failed!")
            sys.exit(1)
    
    except Exception as e:
        print(f"\n❌ Test failed with error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
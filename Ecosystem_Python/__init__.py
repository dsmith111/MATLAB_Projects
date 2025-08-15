"""
Ecosystem Python - A port of the MATLAB ecosystem simulation

This package implements a complex predator-prey ecosystem simulation with
intelligent creature behavior, following Lotka-Volterra dynamics.

Main modules:
- creature: Base creature class with AI behavior
- herbivore: Herbivore creature subclass
- predator: Predator creature subclass  
- plant: Plant entity class
- world_manager: World state management and visualization
- ecosystem: Main interactive simulation
- ecosystem_headless: Non-interactive simulation for testing

Usage:
    from ecosystem_python import ecosystem
    # Run interactive simulation
    
    from ecosystem_python.ecosystem_headless import run_simulation
    # Run programmatic simulation
"""

__version__ = "1.0.0"
__author__ = "Ported from MATLAB by AI Assistant"

from .creature import Creature
from .herbivore import Herbivore
from .predator import Predator
from .plant import Plant
from .world_manager import WorldManager

__all__ = ['Creature', 'Herbivore', 'Predator', 'Plant', 'WorldManager']
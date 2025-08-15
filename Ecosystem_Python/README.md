# Ecosystem Python

This is a Python port of the MATLAB ecosystem simulation. It implements a complex predator-prey ecosystem following Lotka-Volterra dynamics with intelligent creature behavior.

## Features

- **Grid-based 2D world** (60x60 default)
- **Complex creature AI** with personality traits and decision making
- **Three entity types**:
  - **Herbivores** (blue stars) - eat plants, flee from predators
  - **Predators** (red X's) - hunt herbivores 
  - **Plants** (green triangles) - food for herbivores
- **Real-time visualization** using matplotlib
- **Population dynamics** following predator-prey models

## Creature Behavior

Each creature has complex behavior driven by:

### Physical Stats
- Health level (0-1)
- Hunger level (0-1) 
- Age (affects health over time)
- Stress level (0-1)

### Personality Traits
- Aggressive vs Placid (0-1)
- Fearful vs Brave (0-1)
- Social vs Isolationist (0-1)

### Actions
- **Reproduce** - when healthy, well-fed, unstressed, and near friends
- **Rest** - when unhealthy but well-fed
- **Eat** - when hungry and food is nearby
- **Attack** - when enemies are near and creature is healthy/unstressed
- **Flee** - when threatened or outnumbered
- **Wander** - default movement behavior

## Installation

1. Install required dependencies:
```bash
pip install -r requirements.txt
```

2. Run the simulation:
```bash
python ecosystem.py
```

## Requirements

- Python 3.7+
- numpy >= 1.20.0
- matplotlib >= 3.5.0
- scipy >= 1.7.0

## Controls

- The simulation runs automatically for 100 iterations
- Press `Ctrl+C` to stop early
- Real-time statistics are printed to console
- Population counts are displayed on the plot legend

## Files

- `ecosystem.py` - Main simulation loop
- `creature.py` - Base creature class with AI behavior
- `herbivore.py` - Herbivore creature subclass
- `predator.py` - Predator creature subclass  
- `plant.py` - Plant entity class
- `world_manager.py` - World state management and visualization
- `requirements.txt` - Python dependencies

## Ecosystem Dynamics

The ecosystem demonstrates emergent behavior where:
- Predator populations rise and fall with herbivore availability
- Herbivore populations are limited by plant resources and predation
- Individual creature intelligence affects survival and reproduction
- Population cycles emerge naturally from individual behaviors

This creates a dynamic system that follows classical predator-prey models while being driven by individual creature decision making rather than top-down population equations.
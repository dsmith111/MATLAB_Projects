#!/usr/bin/env python3
"""
Quick visual test to verify matplotlib plotting works in headless environment
"""

import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend for headless environment
import matplotlib.pyplot as plt
import numpy as np

# Create a simple test plot
plt.figure(figsize=(8, 6))

# Sample data similar to ecosystem
herbivores = np.array([[10, 15], [20, 25], [30, 35]])
predators = np.array([[15, 20], [25, 30]])
plants = np.array([[5, 10], [12, 18], [22, 28], [35, 40]])

plt.scatter(herbivores[:, 1], herbivores[:, 0], c='blue', marker='*', s=50, label='Herbivores')
plt.scatter(predators[:, 1], predators[:, 0], c='red', marker='x', s=50, label='Predators')
plt.scatter(plants[:, 1], plants[:, 0], c='green', marker='^', s=30, label='Plants')

plt.xlim(0, 60)
plt.ylim(0, 60)
plt.legend()
plt.title('Ecosystem Simulation Test')
plt.xlabel('X Position')
plt.ylabel('Y Position')
plt.grid(True, alpha=0.3)

# Save instead of showing since we're in headless environment
plt.savefig('/home/runner/work/MATLAB_Projects/MATLAB_Projects/Ecosystem_Python/test_plot.png', dpi=150, bbox_inches='tight')
print("✅ Plot test successful! Saved test_plot.png")
print("Matplotlib visualization is working correctly.")
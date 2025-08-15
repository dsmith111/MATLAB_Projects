#!/usr/bin/env python3
"""
Example usage of the Python Ecosystem simulation.
This shows how to customize and run the ecosystem with different parameters.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from ecosystem_headless import run_simulation


def main():
    """Demonstrate different ecosystem configurations"""
    
    print("🌱 Python Ecosystem Simulation Examples 🌱\n")
    
    # Example 1: Small world, few iterations
    print("=" * 50)
    print("Example 1: Small ecosystem (30x30, 5 iterations)")
    print("=" * 50)
    stats1 = run_simulation(iterations=5, save_plots=False, world_size=30)
    
    # Example 2: Normal world, more iterations
    print("\n" + "=" * 50)
    print("Example 2: Standard ecosystem (60x60, 10 iterations)")
    print("=" * 50)
    stats2 = run_simulation(iterations=10, save_plots=True, world_size=60)
    
    # Display summary
    print("\n" + "=" * 50)
    print("SIMULATION SUMMARY")
    print("=" * 50)
    
    print("\nSmall Ecosystem Results:")
    if stats1:
        final_stats1 = stats1[-1]
        print(f"  Final populations: H={final_stats1['herbivores']}, "
              f"P={final_stats1['predators']}, Pl={final_stats1['plants']}")
        avg_time1 = sum(s['time'] for s in stats1) / len(stats1)
        print(f"  Average iteration time: {avg_time1:.4f}s")
    
    print("\nStandard Ecosystem Results:")
    if stats2:
        final_stats2 = stats2[-1]
        print(f"  Final populations: H={final_stats2['herbivores']}, "
              f"P={final_stats2['predators']}, Pl={final_stats2['plants']}")
        avg_time2 = sum(s['time'] for s in stats2) / len(stats2)
        print(f"  Average iteration time: {avg_time2:.4f}s")
    
    print("\n🎉 Ecosystem simulation examples completed!")
    print("Check the generated PNG files to see the ecosystem visualizations.")
    print("\nTo run the interactive version (if you have a display):")
    print("  python ecosystem.py")


if __name__ == "__main__":
    main()
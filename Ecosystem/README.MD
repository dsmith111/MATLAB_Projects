<!DOCTYPE HTML>
<html>
  <head>
   <h1>Ecosystem</h1> 
    <body>
      <p>Hello, the following .m program was written in MATLAB to simulate an echo system.
  The goal of the project was to create intelligent enough basic creatures, that their population would follow the <i><strong>Lokta-Volterra</strong></i> predator prey models.</p>

  The current objects within the program are:
  - Plants, they grow over time.
  - Herbivores, they eat plants.
  - Predators, they eat herbivores.
  - Carcasses, decay over time and produce grass in-place.

  In order to simulate an evolving intelligence, the creatures have 'weights' assigned to them which determines their behavior.
  One creature may have an aggression weight of 0.9 on a 0-1 scale, causing it to attack other creatures more frequently.
  In addition, the creatures behaviors are driven by physical and 'emotional' stats, which vary depending on their situation. Such as them seeing too many predators near them.

  Ultimately, the emotional and physical stats are dependent on the individual weights assigned to the creature at birth. If the creature survives long enough, it can pass on these weights to the two offspring it can produce. One off-spring will have slightly modified weight values, the other offspring will have the same. 

  Through this system, the creatures will 'evolve' in a way that leads them to behave more intelligently through their interactions, and give them the ability to adapt to the environment.
  </body>
</html>

classdef Herbivore < Creature
    %Creature which only eats plants
    properties
       
    end
    methods
        function obj = Herbivore(location)
            obj.location = location;
            obj.regen = 0.05;
            obj.damage = 0.1;
            obj.type = "herbivore";
            obj.enemy_type = "predator";
            obj.food_type = "plant";
        end
        
    end
end


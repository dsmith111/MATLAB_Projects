classdef Predator < Creature
    %Creature which hunts other creatures
    properties
       
    end
    methods
        function obj = Predator(location)
            obj.location = location;
            obj.regen = 0.05;
            obj.damage = 0.1;
            obj.type = "predator";
            obj.enemy_type = "herbivore";
            obj.food_type = "carcass";
            obj.stress_thresh = 0.85;
            obj.aggressive_placid = .80;
        end
        
    end
end


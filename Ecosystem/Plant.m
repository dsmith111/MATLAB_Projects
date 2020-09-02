classdef Plant
   
    properties
        type = "plant";
        eaten = false;
        location = [];
    end
    
    methods
        function obj = Plant(location)
            obj.location = location;
        end
    end
end


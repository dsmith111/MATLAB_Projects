classdef Build_World
    % Construct or update world map
    
    methods(Static)
        % Build world
        function object_list = update_list(object_list)
            i = 1;
            
            while i < numel(object_list)

                object = object_list{i};
                
                if (object.type == "herbivore") || (object.type == "predator")
                   
                    % Check health, hunger, remove if dead.
                    object.hunger_level = object.hunger_level - 0.02;
                    
                    if object.health_level <= 0
                        object.alive = false;
                    end
                    
                    if object.hunger_level <= 0
                        object.hunger_level = 0;
                        object = object.hurt();
                    end
                    
                    if object.alive == false
                        object_list(i) = [];
                        continue
                    end
                    
                    if object.age < 50
                        object.age = object.age + 1;
                    else
                        object.age = object.age + 1;
                        object = object.hurt();
                    end
                    object_list{i} = object;
                    
                elseif object.type == "plant"
                    if object.eaten == true
                        object_list(i) = [];
                    end
                end
                
                i = i + 1;
                
                if i > numel(object_list)
                    break
                end
            end
            
            
        end
        
        % Update world
        function draw_map(map_size, object_list)
            %              map = zeros(size);
            %              figure(1)
            hold off;
            scatter(1, 1, 'marker', 'none');
            hold on;
            % Plot initial map
            scatter(map_size, map_size, 'marker', 'none');
            
            for i = 1:numel(object_list)
                focused_object = object_list{i};
                
                switch focused_object.type
                    
                    case "herbivore"
                        scatter(focused_object.location(2),...
                            focused_object.location(1), 'blue', 'marker', '*')
                        
                    case "predator"
                        scatter(focused_object.location(2),...
                            focused_object.location(1), 'red', 'marker', 'x')
                        
                    case "plant"
                        scatter(focused_object.location(2),...
                            focused_object.location(1), 'green', 'marker', '^')
                end
            end
            
        end
    end
end


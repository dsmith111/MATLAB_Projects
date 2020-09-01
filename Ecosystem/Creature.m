classdef Creature
    % Base creature class to be used for predators and herbivores
    
    properties
        type = "none";
        food_type = "none";
        enemy_type = "none";
        action = "none";
        % Status Levels
        stress_level = 0;
        hunger_level = 0.5;
        health_level = 1;
        age = 0;
        mature = 15;
        sight_range = 3;
        times_reproduced = 0;
        max_reproduce = 3;
        
        % Weights
        stress_weight = 0.5;
        hunger_weight = 0.5;
        health_weight = 0.5;
        health_thresh = 0.5;
        hunger_thresh = 0.5;
        stress_thresh = 0.5;
        % Personality Makeup (1 -> 0, first term -> second term)
        aggressive_placid = 0.5;
        fear_brave = 0.5;
        social_isolationist = 0.5;
        
        % Location
        location = [y, x];
        friendlies_close = [];
        enemies_close = [];
        food_close = [];
        friend_distances = [];
        enemy_distances = [];
        food_distances = [];
        other_close = [];
        closest_enemy = [];
        closest_friend = [];
        closest_food = [];
        friend_location = [];
        enemy_location = [];
        food_location = [];
        % List of unformatted objects
        entities_close = [];
        entities_dist= [];
        
    end
    
    methods
        
        % Look
        function obj = process_sight(obj,object_list)
            af_fr = false;
            af_e = false;
            af_fd = false;
            af_o = false;
            
            % Sort through list of known objects
            temp_object_locations = [object_list.location];
            temp_object_locations = reshape(temp_object_locations, 2, []);
            temp_object_locations = temp_object_locations';
            object_dist = [];
            
            for i = 1:size(temp_object_locations,1)
                object_dist(end+1) = pdist2(obj.location,temp_object_locations(i,:));
            end
            
            close_objects_ind = find(object_dist<= obj.sight_range);
            close_objects_list = object_list(close_objects_ind);
            obj.entities_close = close_objects_list;
            obj.entities_dist = object_dist(close_objects_list);
            
            
            for i = 1:numel(close_objects_list)
                
                inspected_object = close_object_list(i);
                creature_xy = inspected_object.location;
                relative_distance = pdist2(obj.location,creature_xy);
                
                if relative_distance <= obj.sight_range
                    
                    switch inspected_object.type
                        
                        case obj.type
                            switch af_fr
                                case true
                                    obj.friendlies_close(end+1) = close_object_list(i);
                                case false
                                    obj.friendlies_close(1) = close_object_list(i);
                                    af_fr = true;
                            end
                            
                        case obj.food_type
                            switch af_fd
                                case true
                                    obj.food_close(end+1) = close_object_list(i);
                                case false
                                    obj.food_close(1) = close_object_list(i);
                                    af_fd = true;
                            end
                            
                        case obj.enemy_type
                            switch af_e
                                case true
                                    obj.enemies_close(end+1) = close_object_list(i);
                                case false
                                    obj.enemies_close(1) = close_object_list(i);
                                    af_e = true;
                            end
                            
                        otherwise
                            switch af_o
                                case true
                                    obj.others_close(end+1) = close_object_list(i);
                                case false
                                    obj.others_close(1) = close_object_list(i);
                                    af_o = true;
                            end  
                    end
                    
                end
            end
            
            % Convert to distances
            % enemies
            for i = 1:numel(obj.closest_enemy)
                yx = obj.closest_enemy(i).location;
                y = yx(1);
                x = yx(2);
                obj.enemy_distances(i) = pdist2(obj.location,[y x]);
            end
            enemy_loc_index = find(obj.enemy_distances == obj.closest_enemy);
            enemy_loc_index = enemy_loc_index(1);
            obj.enemy_location(1) = obj.enemies_close(1);
            obj.enemy_location(2) = obj.enemies_close(2);
            
            
            % friends
            for i = 1:numel(obj.closest_friend)
                yx = obj.closest_friend(i).location;
                y = yx(1);
                x = yx(2);
                obj.friend_distances(i) = pdist2(obj.location,[y x]);
            end
            obj.closest_friend = min(obj.friend_distances);
            obj.closest_friend = obj.closest_friend(1);
            friend_loc_index = find(obj.friend_distances == obj.closest_friend);
            friend_loc_index = friend_loc_index(1);
            obj.friend_location(1) = obj.friendlies_close(1);
            obj.friend_location(2) = obj.friendlies_close(2);
            
            %food
            for i = 1:numel(obj.closest_food)
                yx = obj.closest_food(i).location;
                y = yx(1);
                x = yx(2);
                obj.food_distances(i) = pdist2(obj.location,[y x]);
            end
            food_loc_index = find(obj.food_distances == obj.closest_food);
            food_loc_index = food_loc_index(1);
            obj.food_location(1) = obj.food_close(1);
            obj.food_location(2) = obj.food_close(2);
            
            
        end
        
        % Process Stress
        function obj = process_stress(obj)
            % Calculate stress level
            stress_base = 0.25;
            amount_enemies = numel(obj.enemies_close);
            amount_friends = numel(obj.friendlies_close);
            amount_food = numel(obj.food_close);
            
            % Stress level due to threat
            threat_weight = amount_enemies/((obj.sight_range*2)^2);
            threat_stress = (threat_weight)*stress_base;
            
            % Stress level due to friends
            friend_weight = amount_friends/((obj.sight_range*2)^2);
            friend_stress = (friend_weight*stress_base)+(obj.social_isolationist*(stress_base/2));
            if friend_stress >stress_base
                friend_stress = stress_base;
            end
            
            % Stress level due to food
            food_stress = (obj.hunger_level*(stress_base/2))+(obj.hunger_weight*(stress_base/2));
            
            % Stress level due to health
            health_stress = (obj.health_level*(stress_base/2))+(obj.health_weight*(stress_base/2));
            
            % Stress level
            obj.stress_level = (threat_stress + food_stress + health_stress) - friend_stress;
            
            if obj.stress_level < 0
                obj.stress_level = 0;
                
            elseif obj.stress_level >1
                obj.stress_level = 1;
                
            end
        end
        
        % Think
        function obj = process_thought(obj)
            obj.health_thresh = obj.health_weight * obj.health_level;
            obj.hunger_thresh = obj.hunger_weight * obj.hunger_level;
            obj.stress_thresh = obj.stress_weight * obj.stress_level;
            
            is_mature = obj.age > obj.mature;
            is_full = obj.hunger_level > obj.hunger_thresh;
            is_healthy = obj.health_level > obj.health_thresh;
            is_stressed = obj.stress_level > obj.stress_thresh;
            enemies_near = numel(obj.enemies_close) > 0;
            friends_near = numel(obj.friendlies_close) > 0;
            food_near = numel(obj.food_close) > 0;
            out_numbered = numel(obj.enemies_close) > (numel(obj.friendlies_close)+1);
            
            % Reproduce
            if(is_mature && is_healthy && is_full && ~is_stressed && ...
                    ~enemies_near && friends_near)
                obj.action = "rep";
                
                
                % Rest
            elseif((~is_healthy) && (is_full))
                obj.action = "rest";
                
                
                % Eat
            elseif(~is_full && (min(obj.enemy_distances) > 2 ) && food_near)
                obj.action = "eat";
                % Attack
            elseif(enemies_near && ~is_stressed && is_healthy)
                obj.action = "attack";
                % Flee
            elseif(enemies_near && (is_stressed || ~is_healthy || ...
                    out_numbered))
                obj.action = "flee";
                % Wander
            else
                obj.action = "wander";
            end
            
        end
        
        % Act
        function process_action(obj)
            
            % Which action to select
            switch obj.action
                
                case "rep"
                    child_selection = false;
                    loc_selection = false;
                    loc_temp = false;
                    % Is someone already near, then produce child
                    if obj.closest_friend == 1
                        child_selection = false;
                        count = 0;
                        
                        while ~child_selection
                            y_child = obj.location(1) + randi([-1, 1]);
                            x_child = obj.location(2) + randi([-1, 1]);
                            
                            % Iterate through near by positions to find
                            % spawn point
                            for i = 1:numel(obj.entities_close)
                                xy = obj.entities_close(i);
                                y = xy(1);
                                x = xy(2);
                                
                                if (x_child ~= x) && (y_child ~= y)
                                    child_selection = true;
                                    
                                end
                                
                            end
                            count = count + 1;
                            
                            % If limit reached, stop looking
                            if count == 8
                                break
                            end
                        end
                    end
                    
                    % If friendly is not near, move closer
                    while ~loc_selection && loc_temp    
                        y_temp = obj.location(1) + randi([-1, 1]);
                        x_temp = obj.location(2) + randi([-1, 1]);
                        
                        % Iterate through near by positions to find
                        % spawn point
                        for i = 1:numel(obj.entities_close)
                            xy = obj.entities_close(i);
                            y = xy(1);
                            x = xy(2);
                            
                            if (x_temp ~= x) && (y_temp ~= y)
                                loc_temp = true;
                                
                            end
                            
                        end
                        
                        % Iteratre through pos
                        count = count + 1;
                        
                        % If limit reached, stop looking
                        if count == 8
                            break
                        end
                    end
                    
                    
                case "rest"
                    
                case "eat"
                    
                case "attack"
                    
                case "flee"
                    
                case "wander"
                    
            end
        end
    end
end


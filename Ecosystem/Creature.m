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
        regen = 0.05;
        damage = 0.1;
        nourish = 0.1;
        alive = true;
        
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
        location = [];
        friendlies_close = {};
        enemies_close = {};
        food_close = {};
        friend_distances = [];
        enemy_distances = [];
        food_distances = [];
        other_close = {};
        closest_enemy = struct();
        closest_friend = struct();
        closest_food = struct();
        enemy_loc_index = 0;
        friend_loc_index = 0;
        food_loc_index = 0;
        friend_location = [];
        enemy_location = [];
        food_location = [];
        friendlies_indices =[];
        enemies_indices = [];
        food_indices = [];
        
        % List of unformatted objects
        entities_close = {};
        entities_dist= [];
        child_location = [];
        map_size = 0;
        
    end
    
    methods
        
        % Look
        function obj = process_sight(obj,object_list,map_size)
            obj.map_size = map_size;
            af_fr = false;
            af_e = false;
            af_fd = false;
            af_o = false;
            obj.friendlies_close = {};
            obj.friendlies_indices = [];
            obj.enemies_close = {};
            obj.enemies_indices = [];
            obj.food_close = {};
            obj.food_indices = [];
            
            % Sort through list of known objects
            temp_object_locations = cellfun(@(x) x.location, object_list,...
                                            "UniformOutput", false);
            temp_object_locations = vertcat(temp_object_locations{:});
            object_dist = [];
            
            for i = 1:size(temp_object_locations,1)
                object_dist(end+1) = pdist2(obj.location,temp_object_locations(i,:));
            end
            
            close_objects_ind = find(object_dist <= obj.sight_range);
            close_objects_list = object_list(close_objects_ind);
            obj.entities_close = close_objects_list;
            obj.entities_dist = object_dist(close_objects_ind);
            
            
            for i = 1:numel(close_objects_list)
                
                inspected_object = close_objects_list{i};
                creature_xy = inspected_object.location;
                relative_distance = pdist2(obj.location,creature_xy);
                
                if relative_distance <= obj.sight_range
                    
                    switch inspected_object.type
                        
                        case obj.type
                            switch af_fr
                                case true
                                    obj.friendlies_close(end+1) = close_objects_list(i);
                                    obj.friendlies_indices(end + 1) = i;
                                case false
                                    obj.friendlies_close(1) = close_objects_list(i);
                                    obj.friendlies_indices(1) = i;
                                    af_fr = true;
                            end
                            
                        case obj.food_type
                            switch af_fd
                                case true
                                    obj.food_close(end+1) = close_objects_list(i);
                                    obj.food_indices(end + 1) = i;
                                case false
                                    obj.food_close(1) = close_objects_list(i);
                                    obj.food_indices(1) = i;
                                    af_fd = true;
                            end
                            
                        case obj.enemy_type
                            switch af_e
                                case true
                                    obj.enemies_close(end+1) = close_objects_list(i);
                                    obj.enemies_indices(end + 1) = i;
                                case false
                                    obj.enemies_close(1) = close_objects_list(i);
                                    obj.enemies_indices(1) = i;
                                    af_e = true;
                            end
                            
                        otherwise
                            switch af_o
                                case true
                                    obj.other_close(end+1) = close_objects_list(i);
                                case false
                                    obj.other_close(1) = close_objects_list(i);
                                    af_o = true;
                            end  
                    end
                    
                end
            end
            
            % Convert to distances
            % enemies
            for i = 1:numel(obj.enemies_close)
                yx = obj.enemies_close{i}.location;
                y = yx(1);
                x = yx(2);
                obj.enemy_distances(i) = pdist2(obj.location,[y x]);
            end
            
            obj.enemy_loc_index = find(obj.enemy_distances == min(obj.enemy_distances));
           
            if numel(obj.enemy_loc_index) ~=0 && (numel(obj.enemies_close) ~= 0)
                obj.enemy_loc_index = obj.enemy_loc_index(1);
                obj.closest_enemy = obj.enemies_close{obj.enemy_loc_index};
                obj.enemy_location = obj.closest_enemy.location;
                obj.enemy_loc_index = obj.enemies_indices(obj.enemy_loc_index);
            end
            
            
            % friends
            for i = 1:numel(obj.friendlies_close)
                yx = obj.friendlies_close{i}.location;
                y = yx(1);
                x = yx(2);
                obj.friend_distances(i) = pdist2(obj.location,[y x]);
            end
            
            obj.friend_loc_index = find(obj.friend_distances == min(obj.friend_distances));
            
            if numel(obj.friend_loc_index) ~=0 && (numel(obj.friendlies_close) ~= 0)
                obj.friend_loc_index = obj.friend_loc_index(1);
                obj.closest_friend = obj.friendlies_close{obj.friend_loc_index};
                obj.friend_location = obj.closest_friend.location;
                obj.friend_loc_index = obj.friendlies_indices(obj.friend_loc_index);
            end
            
            %food
            for i = 1:numel(obj.food_close)
                yx = obj.food_close{i}.location;
                y = yx(1);
                x = yx(2);
                obj.food_distances(i) = pdist2(obj.location,[y x]);
            end

            obj.food_loc_index = find(obj.food_distances == min(obj.food_distances));
            
            if numel(obj.food_loc_index) ~=0 && (numel(obj.food_close) ~= 0)
                obj.food_loc_index = obj.food_loc_index(1);
                obj.closest_food = obj.food_close{obj.food_loc_index};
                obj.food_location = obj.closest_food.location;
                obj.food_loc_index = obj.food_indices(obj.food_loc_index);
            end
            
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
            elseif ~is_full && (all(min(obj.enemy_distances) > 2)) && food_near
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
        function [obj, recent_action] = process_action(obj)
            
            recent_action = "nothing";
            
            % Which action to select
            switch obj.action
                
                case "rep"
                    %Is friend near
                    distance = obj.nearest_creature(obj,obj.type);
                    if distance == 1
                        o_location = obj.find_empty(obj);
                        if numel(o_location) ~= 0
                            obj.child_location = o_location;
                            recent_action = "rep";

                        else
                            obj.child_location = [];
                        end

                    % Friend not near
                    elseif distance > 1
                        o_location = obj.find_near_empty(obj, obj.closest_friend.location);

                        if numel(o_location) ~= 0
                           obj.location = o_location;
                        end
                    end
                    
                case "rest"
                    
                    if obj.health_level ~= 1
                        obj = regenerate(obj);
                    end
                    
                case "eat"
                    % Food near
                    distance = obj.nearest_creature(obj,obj.food_type);
                    if distance == 1
                        recent_action = "eat";
                        obj.hunger_level = obj.hunger_level + obj.nourish;

                    % Food not near
                    elseif distance > 1
                        o_location = obj.find_near_empty(obj, obj.closest_food.location);

                        if numel(o_location) ~= 0
                           obj.location = o_location;
                        end
                    end 
                    
                case "attack"
                    
                    % Enemy near
                    distance = obj.nearest_creature(obj,obj.enemy_type);
                    if distance == 1
                        recent_action = "attack";
                        
                    % Enemy not near
                    elseif distance > 1
                        o_location = obj.find_near_empty(obj, obj.closest_enemy.location);

                        if numel(o_location) ~= 0
                           obj.location = o_location;
                        end
                    end                     
                    
                case "flee"
                    o_location = obj.find_near_empty(obj, obj.closest_enemy.location, "flee");
                    
                    if numel(o_location) ~= 0
                        obj.location = o_location;
                    end
                    
                case "wander"
                    o_location = obj.find_empty(obj, 0, true);
                    
                    if numel(o_location) ~= 0
                        obj.location = o_location;
                    end
            end
        end
        
        % Regen
        function obj = regenerate(obj)
            obj.health_level = obj.health_level + obj.regen;
        end
        
        % Hurt
        function obj = hurt(obj)
           obj.health_level = obj.health_level - obj.damage;
        end
    end
    
    methods(Static)
        
        function distance = nearest_creature(object,type)
            % Function for finding nearest POI
            
            % Finding the nearest one's euclidean distance
            objects_near = object.entities_close;
            distance = inf;
            
            for i = 1:numel(objects_near)
                
                if objects_near{i}.type == type
                    iteration_distance = pdist2(object.location,objects_near{i}.location);
                    
                    if iteration_distance < distance
                        distance = iteration_distance;
                        
                    end
                end
            end
            
            if distance == inf
                distance = 0;
            end
            
        end

        function location = find_empty(object, iteration_skip, random_sel)
            % Function for finding the nearest empty tile
            if nargin < 2
                iteration_skip = 0;
                random_sel = false;
            
            elseif nargin < 3
                random_sel = false;
            end
            
            map_size = object.map_size;
            
            location = [];
            near_objects = object.entities_close;
            
            % Create array of possible areas to check
            locations_check = [];
            count = 1;
            for i = -1:1
                
                for k = -1:1
                    
                    if (i == 0) && (k == 0)
                        continue
                    end
                    yx = object.location;
                    y = yx(1);
                    x = yx(2);
                    n_y = y + i;
                    n_x = x + k;
                    if (n_y > object.map_size) || (n_x > object.map_size)...
                            || (n_y) < 1 || n_x < 1
                        continue
                    end
                    locations_check(count,:) = [n_y n_x]; %#ok<*AGROW>
                    count = count + 1;
                    
                end
                
            end
            
            if random_sel == true
                locations_check = locations_check(randperm(size(locations_check, 1)), :);
            end
            % Iterate through locations to check and iterate through locations
            for i = 1:length(locations_check)
                
                for k = 1:numel(near_objects)
                    logical_loc = near_objects{k}.location == locations_check(i,:);
                    if (length(map_size) < length(locations_check(i)))
                       continue 
                    end
                        
                    if ~all(logical_loc)
                        location = locations_check(i, :);
                        % Used to look for different spot
                        if iteration_skip > 0
                            iteration_skip = iteration_skip - 1;
                            location = [];
                            continue
                        end
                        
                        break
                        
                    end
                end
            end

       end

        function location = find_near_empty(object, POI_location, pursuit)
            % Function for finding closest movement position

            % Default final argument
            if nargin < 3
               pursuit = "pursue"; 
            end
            location = object.location;
            distance = pdist2(object.location,POI_location);

            for i = 0:7 
                checked_location = object.find_empty(object,i);

                if numel(checked_location) == 0
                   continue 
                end

                checked_distance = pdist2(checked_location,POI_location);

                switch pursuit

                    case "pursue"
                        if checked_distance < distance && checked_distance ~= 0
                           location = checked_location; 
                        end

                    case "flee"
                        if checked_distance > distance
                            location = checked_location;
                        end
                end
            end

        end
        
    end
end


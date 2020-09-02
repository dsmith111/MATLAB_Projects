clf
clear
% clf
hold on;

% Size of world
size = 60;

% Creature_sets

% Number of creatures
amount_herb = round((size/3),1);
amount_pred = round((size/8),1);
amount_plant = round((size/2),1);

total_objects = sum([amount_herb amount_pred amount_plant]);
% Create randomized list of locations to assign to objects
randomized_locations = [];
for i = 1:total_objects
    r = randi(size-1);
    c = randi(size-1);
    
    if i == 1
        randomized_locations(i, :) = [r c];
        continue
    end
    
    for k = 1:numel(randomized_locations)
        if all(ismember([r c],randomized_locations(k,:)))
            continue
        end
        randomized_locations(i, :) = [r c];
        break
    end 
end

% Initialize creatures

object_list = {};
for i = 1:total_objects
    
   if i <= amount_herb
       selector = 1;
   
   elseif i <= (amount_herb + amount_pred)
       selector = 2;
       
   elseif i > (amount_herb + amount_pred)
       selector = 3;
       
   end
   
   switch selector
       case 1
           object = Herbivore([randomized_locations(i,:)]);
       case 2
           object = Predator([randomized_locations(i,:)]);
       case 3
           object = Plant([randomized_locations(i, :)]);
   end
    
   object_list{i} = object;
end


% Run simulation

for i = 1:100
    tic
    % Update Objects
    for k = 1:numel(object_list)
       focused_object = object_list{k};
       if focused_object.type == "plant"
           continue
       end
       focused_object = focused_object.process_sight(object_list,size);
       focused_object = focused_object.process_stress();
       focused_object = focused_object.process_thought();
       [focused_object, action] = focused_object.process_action();
       
       switch action
           case "rep"
               child = Herbivore(focused_object.child_location);
               object_list{end+1} = child;
               
           case "attack"
               enemy = object_list{focused_object.enemy_loc_index};
               enemy = enemy.hurt();
               object_list{focused_object.enemy_loc_index} = enemy;
               
           case "eat"
               food = object_list{focused_object.food_loc_index};
               food.eaten = true;
               object_list{focused_object.food_loc_index} = food;
       end
       object_list{k} = focused_object;
    end
    object_list = Build_World.update_list(object_list);
    Build_World.draw_map(size, object_list);
    drawnow
    toc
end
%% Conway
clear
clf
hold off;
%Initiate grid
grid = rand(102)>0.7;
grid(:,1) =0;
grid(1,:)=0;
grid(:,end)=0;
grid(end,:)=0;
pcolor(grid)
drawnow
% Determine Neighbors
r=0;
c=0;

neigh = 0;
%Initiate Amount of neighbors grid
gridN = zeros(102);

%Simulate and Display Grid State
for k = 1:10000
%Initiate and blank Future grid State
gridF = zeros(102);
%For loop to Determine states of cells
for i = 2:(length(grid)-1)
    for j = 2:(length(grid)-1)
        r = i;
        c = j;
        nA = fillA(r,c);
        coord = sub2ind([102 102],i,j);
        [n1,n2,n3,n4,n5,n6,n7,n8] =  fillA(r,c);
        neigh = grid(sub2ind([102 102],n1(1),n1(2)))+grid(sub2ind([102 102],n2(1),n2(2)))+grid(sub2ind([102 102],n3(1),n3(2)))+grid(sub2ind([102 102],n4(1),n4(2)))+grid(sub2ind([102 102],n5(1),n5(2)))+grid(sub2ind([102 102],n6(1),n6(2)))+grid(sub2ind([102 102],n7(1),n7(2)))+grid(sub2ind([102 102],n8(1),n8(2)));
        gridN(sub2ind([102 102],i,j)) = neigh;
        %Survive, Reproduce or Die
        if(neigh == 3 )
            gridF(coord) = 1;
        elseif((neigh < 2) || (neigh > 3))
            gridF(coord) = 0;
        else
            gridF(coord) = grid(coord);
            
        end
    end
    
end
grid = gridF;

pcolor(grid)
drawnow



end

function [n1,n2,n3,n4,n5,n6,n7,n8] = fillA(r,c)
    %Neighbor RC
n1 = [r-1,c-1];
n2 = [r-1,c];
n3 = [r-1,c+1];
n4 = [r,c-1];
n5 = [r,c+1];
n6 = [r+1,c-1];
n7 = [r+1,c];
n8 = [r+1,c+1];
end

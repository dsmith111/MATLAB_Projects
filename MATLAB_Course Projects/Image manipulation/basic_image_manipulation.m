%% Homework 6
% Clear Prior Data
clf
clear
% Read and Convert Lantern image to binary
E = imread('chlantern.jpg');
D = rgb2gray(E);

D = imbinarize(D);
% Invert Image
D= imcomplement(D);

D = bwareaopen(D,39000);
D = imfill(D,'holes');
imshow(E)

c = bwconncomp(D)
numObj = c.NumObjects;
tle = string(numObj);
tle = append('Number of Objects: ',tle);
title(tle);

%imshow(A)


%% Counting Circles
clf
clear
F = imread('harry.jpg');
E = imcomplement(F);
E = imfill(E,"holes");
imshow(F)
[r c] = size(E);
[centers, radi, metric] = imfindcircles(E,[34 38],'Sensitivity',0.965,'ObjectPolarity','bright');
viscircles(centers,radi)

% The imfindcircles command uses a circular hough transform based
% algorithm. The algorithm essentially sends out rays from each point to
% determine where the center of a possible circle is.

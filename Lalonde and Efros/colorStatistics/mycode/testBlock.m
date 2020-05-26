function testBlock 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
B = rand(500,500,3);
[nrows, ncols] = size(B(:,:,1));

%% First way: get the coordinates of the centers of our blocks
% This is *wayyyy* slower!
tic;
[x,y] = meshgrid(2:nrows-1, 2:ncols-1);

r = reshape(x, 1, size(x,1)*size(x,2));
c = reshape(y, 1, size(y,1)*size(y,2));

rTot = repmat(r, 9, 1);
cTot = repmat(c, 9, 1);

rTot([1 2 3],:) = rTot([1 2 3],:) - 1;
rTot([7 8 9],:) = rTot([7 8 9],:) + 1;

cTot([1 4 7],:) = cTot([1 4 7],:) - 1;
cTot([3 6 9],:) = cTot([3 6 9],:) + 1;

for j=1:size(rTot,2)
    w = reshape(repmat(1:3, size(rTot, 1), 1), size(rTot,1)*3, 1);
    ind = sub2ind(size(B), repmat(rTot(:,j), 3, 1), repmat(cTot(:,j), 3, 1), w);
    block = permute(reshape(B(ind), 3, 3, 3), [2 1 3]);
end
toc;

%% Try the other way -> much much more efficient!
tic;
for i=2:nrows-1
    for j=2:ncols-1
        block = B(i-1:i+1, j-1:j+1, :);
%         patch = reshape(B(i-1:i+1, j-1:j+1, :), 9, 3);
        % sort the patch colors along the L dimension (first dimension)
        
%         [s, ind] = sort(patch(:,1));
%         patch = reshape(patch(ind, :), 1, 27);
% 
%         % compute the distance from the patch to every other cluster center
%         distSq = sum((args.ClusterCenters - repmat(patch', 1, nbClusters)).^2, 2);
%         % find the closest, and assign the texton to the corresponding cluster's index
%         [minDist, ind] = min(distSq);
%         quantizedPatches((i-2)*254+j-1) = ind;
    end
end
toc;
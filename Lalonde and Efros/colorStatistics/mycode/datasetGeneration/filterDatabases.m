%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [imageInd, objectInd] = filterDatabases(imageDb, objectDb)
%   Retrieves the objects and the images that correspond to certain criterions
% 
% Input parameters:
%   - imageDb: image database
%   - objectDb: object database
%
% Output parameters:
%   - imageInd: indices of images which correspond to the constraints
%   - objectInd: indices of objects which correspond to the constraints
%   - objectToImageInd: mapping between an object's index and its corresponding image
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [imageInd, objectInd, objectToImageInd] = filterDatabases(imageDb, objectDb) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% All images are good (presumably)
imageInd = 1:length(imageDb); 

minArea = 0.05;
maxArea = 0.6;

% Compute the correspondence between objects and images
objectToImageInd = getObjectToImageInd(imageDb(imageInd), objectDb);

% Compute the area of each object
polygons = convertPolygonsFromXML(objectDb);
imageAreas = arrayfun(@(x) str2double(x.document.image.size.width)*str2double(x.document.image.size.height), objectDb);
objectAreas = cellfun(@(x) polyarea(x(:,1), x(:,2)), polygons);
ratios = objectAreas ./ imageAreas(objectToImageInd);

% objects which are sufficiently large
indLarge = ratios >= minArea;

% objects that aren't too large
indSmall = ratios <= maxArea;

objectInd = find(indSmall & indLarge);
objectToImageInd = objectToImageInd(objectInd);

% Last test: make sure all the filenames correspond
if ~isempty(find(~arrayfun(@(o,i) strcmp(o.document.image.filename, i.document.image.filename), objectDb(objectInd), imageDb(imageInd(objectToImageInd)), 'UniformOutput', 1)))
    error('filterDatabases: last indices mismatch!');
end 

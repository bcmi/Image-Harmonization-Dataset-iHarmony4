%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function objectToImageInd = getObjectToImageInd(imageDb, objectDb)
%   Determines the correspondence between objects and their corresponding images in databases.
% 
% Input parameters:
%   - imageDb: the image database
%   - objectDb: the object database
%
% Output parameters:
%   - objectToImageInd: mapping from object to image in the database
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function objectToImageInd = getObjectToImageInd(imageDb, objectDb) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for each image what are the indices of its corresponding objects?
objectToImageInd = zeros(length(objectDb), 1);
% folders = {objectDb(:).document.image.folder};
% images = {objectDb(:).document.image.filename};
folders = arrayfun(@(x)x.document.image.folder, objectDb, 'UniformOutput', 0);
images = arrayfun(@(x)x.document.image.filename, objectDb, 'UniformOutput', 0);

for j=1:length(imageDb)
    % find the corresponding folder
    folderInd = strcmp(folders, imageDb(j).document.image.folder);
    
    % find the corresponding image
    objectInd = strcmp(images(folderInd), imageDb(j).document.image.filename); 
    
    t = find(folderInd);
    objectToImageInd(t(objectInd)) = j;
end
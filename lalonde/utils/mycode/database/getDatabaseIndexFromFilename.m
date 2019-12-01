%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function index = getDatabaseIndexFromFilename(database, topField, folder, filename)
%   Returns the index of an image in a database, based on folder and filename matching
% 
% Input parameters:
%   database: the input database
%   topField: top-field of the xml structure (see notes below)
%   folder: folder name to match
%   filename: file name to match
%
% Output parameters:
%   index: index of the corresponding folder/filename in the database. Empty if not found
%
% Notes:
%   - Uses the (topField).image.folder and (topField).image.filename structure to access the
%   database information
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function index = getDatabaseIndexFromFilename(database, topField, folder, filename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

folderInd = find(arrayfun(@(x) strcmp(x.(topField).image.folder, folder), database));
index = arrayfun(@(x) strcmp(x.(topField).image.filename, filename), database(folderInd));
index = folderInd(index);
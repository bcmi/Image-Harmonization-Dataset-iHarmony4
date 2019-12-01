%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function clursterTextons
%   Cluster all the 3x3 patches in the training database into textons
% 
% Input parameters:
%
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doLoad3x3Patchesglobal patches3x3;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load the database
addpath '../database';

imagesPath = '/nfs/hn21/projects/labelme/Images/';
annotationsPath = '/nfs/hn21/projects/labelme/Annotation/';
subDirs = {'spatial_envelope_256x256_static_8outdoorcategories'};

dbFn = @dbFnLoad3x3Patches;
% Load all the 3x3 patches in memory
processDatabase(imagesPath, subDirs, annotationsPath, '', dbFn);

save patches3x3.mat patches3x3;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doLoadNxNPatches
%   Cluster all the NxN patches in the training database into textons
% 
% Input parameters:
%
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function patches = doLoadNxNPatchesglobal patches;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load the database
addpath '../database';

imagesPath = '/nfs/hn21/projects/labelme/Images/';
annotationsPath = '/nfs/hn21/projects/labelme/Annotation/';
outputPath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesTextons/';
subDirs = {'spatial_envelope_256x256_static_8outdoorcategories'};

% N must be odd
N = 5;

dbFn = @dbFnLoadNxNPatches;
% Load all the NxN patches in memory
processDatabase(imagesPath, subDirs, annotationsPath, '', dbFn, 'N', N);

save(fullfile(outputPath, sprintf('patches%dx%d_unsorted.mat', N, N)), 'patches');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doCoOccurencesGMM
%   
% 
% Input parameters:
%
%   - varargin: Possible values:
%     - 'Recompute':
%       - 0: (default) will not compute the histogram when results are
%         already available. 
%       - 1: will re-compute histogram no matter what
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doCoOccurencesGMMglobal histoIndices;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath '../database/';
addpath ../../3rd_party/parseArgs;

% define the input and output paths
imagesBasePath = '/nfs/hn21/projects/labelme/Images/';
annotationsBasePath = '/nfs/hn21/projects/labelme/Annotation/';
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesGMM';
subDirs = {'spatial_envelope_256x256_static_8outdoorcategories'};

colorSpaces{1} = 'lab';
colorSpaces{2} = 'rgb';

nbBins = 32;
for i=1:length(colorSpaces)
    histoIndices{i} = cell(1, nbBins^3);%zeros(nbBins, nbBins, nbBins);
end

dbFn = @dbFnCoOccurencesGMM;

%% Call the database function
processDatabase(imagesBasePath, subDirs, annotationsBasePath, outputBasePath, dbFn, 'ColorSpaces', colorSpaces);

save(fullfile(outputBasePath, sprintf('histoIndices_%d.mat', nbBins)), 'histoIndices');
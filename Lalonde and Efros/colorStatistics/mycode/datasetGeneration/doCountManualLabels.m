%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doCountManualLabels
%   Count how many images have been labeled so far
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
function doCountManualLabels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath ../
setPath;

global counts totNbLabelers countsAll countsTot countsClasses;

% define the input and output paths
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/dataset/filteredDb/Annotation';

dbFn = @dbFnCountManualLabels;

totNbLabelers = 3;
counts = zeros(totNbLabelers, 1);
countsAll = 0; countsTot = 0;
countsClasses = zeros(2, 1); % 1=realistic, 2=unrealistic

% call the database function
parallelized = 0; randomized = 0;
processResultsDatabaseFast(dbPath, 'image_0', '', dbFn, parallelized, randomized);

fprintf('Total of %d labeled images\n', countsTot);
fprintf('%d realistic, %d unrealistic\n', countsClasses(1), countsClasses(2));
fprintf('I labeled %d images, Alyosha labeled %d images and James labeled %d images\n', counts(1), counts(2), counts(3));
fprintf('%d images were labeled by everyone\n', countsAll);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnManualLabelTestSet
%   Manually label the test set
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r=dbFnCountManualLabels(outputBasePath, annotation, varargin)
global counts totNbLabelers countsAll countsTot countsClasses;
    
r=0;
if isfield(annotation, 'class')
    nbLabelers = length(annotation.class);
    for i=1:nbLabelers
        labelerId = sscanf(annotation.class(i).labelerId, '%d');
        counts(labelerId) = counts(labelerId) + 1;
    end
    if strcmp(annotation.class(1).type, 'r')
        countsClasses(1) = countsClasses(1) + 1;
    elseif strcmp(annotation.class(1).type, 'u')
        countsClasses(2) = countsClasses(2) + 1;
    end
    if nbLabelers == totNbLabelers
        countsAll = countsAll + 1;
    end
    countsTot = countsTot + 1;
end

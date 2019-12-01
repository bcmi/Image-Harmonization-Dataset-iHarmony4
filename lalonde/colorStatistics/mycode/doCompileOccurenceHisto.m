%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doCompileOccurenceHisto
%   Scripts that computes the entire occurence results. Simply adds up all
%   the matrices generated until now
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doCompileOccurenceHistoglobal cumulative1stOrder cumulative2ndOrder colorSpaces;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath '../database/';

% define the input and output paths
imagesBasePath = '/nfs/hn21/projects/labelme/Images/';
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesHisto/';
subDirs = {'spatial_envelope_256x256_static_8outdoorcategories'};
dbFn = @dbFnCompileOccurence;

total1stOrder = [];
total2ndOrder = [];
colorSpaces = [];

% initialize the cumulative co-occurences to empty
cumulative1stOrder = [];
cumulative2ndOrder = [];

% call the database function
processGenericDatabase(imagesBasePath, subDirs, outputBasePath, dbFn);

% save the info for all the color spaces at the same time
save(fullfile(outputBasePath, 'total1st.mat'), 'cumulative1stOrder', 'colorSpaces');
save(fullfile(outputBasePath, 'total2nd.mat'), 'cumulative2ndOrder', 'colorSpaces');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnCompileOccurence(imgPath, imagesBasePath, outputBasePath, annotation, varargin)
%   Accumulates co-occurence results.
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dbFnCompileOccurence(imgPath, imagesBasePath, outputBasePath, annotation, varargin)
global cumulative1stOrder cumulative2ndOrder colorSpaces;

addpath ../../3rd_party/parseArgs;

% check if the user specified the option to recompute
defaultArgs = struct('Recompute', 1);
args = parseargs(defaultArgs, varargin{:});

% read the image and the xml information
[img, imgInfo, recompute, xmlPath] = readImageInfo(imgPath, outputBasePath, annotation, 'colorStatistics', args.Recompute);

% look if the information was computed
if isfield(imgInfo, 'colorStatistics') 
    
    % loop over all the computed color spaces
    for i=1:size(imgInfo.colorStatistics, 2)
        % read the 1st order
        filePath = fullfile(outputBasePath, annotation.folder, imgInfo.colorStatistics(i).firstOrder.file);
        nbBins1stOrder = sscanf(imgInfo.colorStatistics(i).firstOrder.nbBins, '%f');
        % this will load the 1st order statistics
        hist1stOrder = [];
        load(filePath);

        % reshape the matrix
        hist1stOrder = reshape(full(hist1stOrder), repmat(nbBins1stOrder, 1, 3));

        if size(cumulative1stOrder, 2) < i
            cumulative1stOrder{i} = hist1stOrder;
        else
            cumulative1stOrder{i} = cumulative1stOrder{i} + hist1stOrder;
        end

        % read the 2nd order
        filePath = fullfile(outputBasePath, annotation.folder, imgInfo.colorStatistics(i).secondOrder.file);
        nbBins2ndOrder = sscanf(imgInfo.colorStatistics(i).secondOrder.nbBins, '%f');

        % load the .mat file
        hist2ndOrder = [];
        load(filePath);

        % reshape the matrix
        hist2ndOrder = reshape(full(hist2ndOrder), repmat(nbBins2ndOrder, 1, 6));

        if size(cumulative2ndOrder, 2) < i
            cumulative2ndOrder{i} = hist2ndOrder;
        else
            cumulative2ndOrder{i} = cumulative2ndOrder{i} + hist2ndOrder;
        end
        
        % store the color space
        if size(colorSpaces, 2) < i
            colorSpaces{i} = imgInfo.colorStatistics(i).colorSpace;
        end
    end
end


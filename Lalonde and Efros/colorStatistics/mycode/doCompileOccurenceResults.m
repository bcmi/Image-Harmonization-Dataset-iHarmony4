%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doCompileOccurenceResults
%   Scripts that computes the entire occurence results. Simply adds up all
%   the matrices generated until now
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doCompileOccurenceResultsglobal cumulative1stOrder cumulative2ndOrder colorSpaces;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath '../database/';

% define the input and output paths
imagesBasePath = '/nfs/hn21/projects/naturalSceneCategories/';
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/naturalSceneCategories/';
dbFn = @dbFnCompileOccurence;

dirsList = {'coast', 'forest', 'highway', 'insideCity', 'mountain', 'openCountry', 'street', 'tallBuilding'};

total1stOrder = [];
total2ndOrder = [];
colorSpaces = [];

for i=1:length(dirsList)
    % define subdirectories to use for the training images
    trainingImagesSubDirs = {dirsList{i}};

    % initialize the cumulative co-occurences to empty
    cumulative1stOrder = [];
    cumulative2ndOrder = [];

    % call the database function
    processGenericDatabase(imagesBasePath, trainingImagesSubDirs, outputBasePath, dbFn, 'Recompute', 0);
    
    % loop over the different color channels extracted
    for j=1:size(cumulative1stOrder, 2)
        % normalize
        cumulative1stOrder{j} = cumulative1stOrder{j} ./ sum(cumulative1stOrder{j}(:));
        cumulative2ndOrder{j} = cumulative2ndOrder{j} ./ sum(cumulative2ndOrder{j}(:));

        if size(total1stOrder, 2) < j
            total1stOrder{j} = cumulative1stOrder{j};
        else
            total1stOrder{j} = total1stOrder{j} + cumulative1stOrder{j};
        end
        if size(total2ndOrder, 2) < j
            total2ndOrder{j} = cumulative2ndOrder{j};
        else
            total2ndOrder{j} = total2ndOrder{j} + cumulative2ndOrder{j};
        end
    end

    % save the info for all the color spaces at the same time
    save(sprintf('%s_1st.mat', dirsList{i}), 'cumulative1stOrder', 'colorSpaces');
    save(sprintf('%s_2nd.mat', dirsList{i}), 'cumulative2ndOrder', 'colorSpaces');
end

save('total1st.mat', 'total1stOrder', 'colorSpaces');
save('total2nd.mat', 'total2ndOrder', 'colorSpaces');


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
defaultArgs = struct('Recompute', 0);
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




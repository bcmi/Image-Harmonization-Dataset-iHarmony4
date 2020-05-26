%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doCompileOccurenceHistoMarginals
%   Scripts that computes the entire occurence results. Simply adds up all
%   the matrices generated until now
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doCompileOccurenceHistoMarginals(type)global cumulative1stOrderMarginal cumulative2ndOrderMarginal cumulative1stOrderPairwise cumulative2ndOrderPairwise;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath '../database/';

% define the input and output paths
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesHistoMarginals/';
subDirs = {'spatial_envelope_256x256_static_8outdoorcategories', ...
    'static_coast_landscape_outdoor', 'static_256x256_web_globalandscape', ...
    'static_outdoor_nature_florida_photos_by_fredo_durand', ...
    'static_outdoor_nature_galapagos_photos_by_fredo_durand', ...
    'static_outdoor_nature_tanzania_photos_by_fredo_durand', ...
    'static_nature_web_outdoor_animal', 'static_newyork_city_urban'};
subDirs = {'static_nature_web_outdoor_animal'};
dbFn = @dbFnCompileOccurence;

colorSpaces{1} = 'lab';
colorSpaces{2} = 'rgb';
colorSpaces{3} = 'hsv';

% initialize the cumulative co-occurences to empty
for i=1:length(colorSpaces)
    cumulative1stOrderMarginal{i} = [];
    cumulative2ndOrderMarginal{i} = [];
    cumulative1stOrderPairwise{i} = [];
    cumulative2ndOrderPairwise{i} = [];
end

% call the database function
processResultsDatabase(dbPath, dbPath, subDirs, dbFn, 'Type', type, 'ColorSpaces', colorSpaces);

% save the info for all the color spaces at the same time
switch type
    case '1'
        save(fullfile(dbPath, 'total1stMarginal.mat'), 'cumulative1stOrderMarginal');
    case '2'
        save(fullfile(dbPath, 'total2ndMarginal.mat'), 'cumulative2ndOrderMarginal');
    case '3'
        save(fullfile(dbPath, 'total1stPairwise.mat'), 'cumulative1stOrderPairwise');
    case '4'
        save(fullfile(dbPath, 'total2ndPairwise.mat'), 'cumulative2ndOrderPairwise');
    otherwise
        error('Unknown type %d', type);
end

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
function dbFnCompileOccurence(imgInfo, dbPath, outputBasePath, varargin)
global cumulative1stOrderMarginal cumulative2ndOrderMarginal cumulative1stOrderPairwise cumulative2ndOrderPairwise

addpath ../../3rd_party/parseArgs;

% check if the user specified the option to recompute
defaultArgs = struct('Recompute', 1, 'Type', '1', 'ColorSpaces', []);
args = parseargs(defaultArgs, varargin{:});

% read the image and the xml information
% [img, imgInfo, recompute, xmlPath] = readImageInfo(imgPath, outputBasePath, imgInfo.image, 'colorStatistics', args.Recompute);

fprintf('Processing %s', imgInfo.image.filename);
% look if the information was computed
for i=1:length(args.ColorSpaces)
    switch args.Type
        case '1'
            % read the 1st order marginal
            filePath = fullfile(outputBasePath, imgInfo.image.folder, imgInfo.colorStatistics(i).firstOrder.marginal.file);

            % this will load the 1st order statistics
            hist1stOrderMarginal = [];
            load(filePath);

            if isempty(cumulative1stOrderMarginal{i})
                cumulative1stOrderMarginal{i} = hist1stOrderMarginal;
            else
                cumulative1stOrderMarginal{i} = cumulative1stOrderMarginal{i} + hist1stOrderMarginal;
            end

        case '2'

            % read the 2nd order marginal
            filePath = fullfile(outputBasePath, imgInfo.image.folder, imgInfo.colorStatistics(i).secondOrder.marginal.file);
            nbBins2ndOrderMarginal = sscanf(imgInfo.colorStatistics(i).secondOrder.marginal.nbBins, '%f');

            % load the .mat file
            hist2ndOrderMarginal = [];
            load(filePath);

            % reshape the matrix
            hist2ndOrderMarginal = reshape(full(hist2ndOrderMarginal), [3 nbBins2ndOrderMarginal nbBins2ndOrderMarginal]);

            if isempty(cumulative2ndOrderMarginal{i})
                cumulative2ndOrderMarginal{i} = hist2ndOrderMarginal;
            else
                cumulative2ndOrderMarginal{i} = cumulative2ndOrderMarginal{i} + hist2ndOrderMarginal;
            end

        case '3'
            % read the 1st order pairwise
            filePath = fullfile(outputBasePath, imgInfo.image.folder, imgInfo.colorStatistics(i).firstOrder.pairwise.file);
            nbBins1stOrderPairwise = sscanf(imgInfo.colorStatistics(i).firstOrder.pairwise.nbBins, '%f');

            % this will load the 1st order statistics
            hist1stOrderPairwise = [];
            load(filePath);

            % reshape the matrix
            hist1stOrderPairwise = reshape(full(hist1stOrderPairwise), [3 nbBins1stOrderPairwise nbBins1stOrderPairwise]);

            if isempty(cumulative1stOrderPairwise{i})
                cumulative1stOrderPairwise{i} = hist1stOrderPairwise;
            else
                cumulative1stOrderPairwise{i} = cumulative1stOrderPairwise{i} + hist1stOrderPairwise;
            end

        case '4'
            % read the 2nd order pairwise
            filePath = fullfile(outputBasePath, imgInfo.image.folder, imgInfo.colorStatistics(i).secondOrder.pairwise.file);
            nbBins2ndOrderPairwise = sscanf(imgInfo.colorStatistics(i).secondOrder.pairwise.nbBins, '%f');

            % load the .mat file
            hist2ndOrderPairwise = [];
            load(filePath);

            % reshape the matrix
            hist2ndOrderPairwise = reshape(full(hist2ndOrderPairwise), [3 repmat(nbBins2ndOrderPairwise, 1, 4)]);

            if isempty(cumulative2ndOrderPairwise{i})
                cumulative2ndOrderPairwise{i} = hist2ndOrderPairwise;
            else
                cumulative2ndOrderPairwise{i} = cumulative2ndOrderPairwise{i} + hist2ndOrderPairwise;
            end

        otherwise
            error('Unknown type %d', args.Type);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doCompileOccurencesGMM
%   
% 
% Input parameters:
%   - type: color space type. (1=lab, 2=rgb)
%   - params: parameters of GMM. (1=full covariance, 6 mixtures; 2=diagonal covariance, 12 mixtures)
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doCompileOccurenceGMM(type, params) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load paths
addpath ../../3rd_party/LabelMeToolbox;
addpath ../../3rd_party/color;
addpath ../../3rd_party/netlab;
addpath ../histogram;


% load('tmp.mat');
% type=1;
% params = 1;

pathGMM = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesGMM/histoIndices.mat';

% load the computed cube of indices
load(pathGMM);

% load the training database
imagesBasePath = '/nfs/hn21/projects/labelme/Images/';
annotationsBasePath = '/nfs/hn21/projects/labelme/Annotation/';
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesGMM/';
subDirs = {'spatial_envelope_256x256_static_8outdoorcategories'};

colorSpaces{1} = 'lab';
colorSpaces{2} = 'rgb';

paramsType{1} = 'full2';
paramsType{2} = 'spherical6';

nbBins = 64;

%% Load the database
fprintf('Loading the database...');
load('dbGMM.mat');% D = LMdatabase(annotationsBasePath, subDirs);
fprintf('done.\n');

% Initialize the results (full gaussian w/ 2 components, spherical gaussian w/ 6 components)
histoGMM = cell(1, nbBins^3);%zeros(nbBins, nbBins, nbBins);

fid = fopen(sprintf('doCompileOccurenceGMM_%d_%d.log', type, params),'w');

%% Main processing
% loop over all the colors in the cube
fprintf('Looping over all colors in the cube\n');
maxNbPixels = 50000; % impose the maximum number of pixels to be 50,000, randomly sampled from the pixels
for i=1:length(histoIndices{type})
    if mod(i,2000) == 0
        fprintf('%d...', i);
        fprintf(fid, '%d...', i);
    end
    % load the corresponding images and accumulate the pixels
    imgInd = histoIndices{type}{i};
    
    % stack 10% of the pixels of each image into one big vector
    pixels = [];
    for j=histoIndices{type}{i}
        img = imread(fullfile(imagesBasePath, D(j).annotation.folder, D(j).annotation.filename));

        if type == 1
            img = rgb2lab(img);
        end
        
        img = single(reshape(img, size(img,1)*size(img,2), 3));
        % randomly pick 10% of the pixels to avoid filling up memory like crazy
        randInd = randperm(size(img,1));
        randInd = randInd(1:floor(0.1*size(img,1)));

        pixels = [pixels; img(randInd,:)];
    end

    try
        % run EM on the 3-D pixels
        if ~isempty(pixels)
            % only select a fraction of pixels if there are too many of them (randomly select)
            if size(pixels, 1) > maxNbPixels
                pxInd = randperm(size(pixels,1));
                pxInd = pxInd(1:maxNbPixels);
            else
                pxInd = 1:size(pixels,1);
            end

            if params == 1
                ncentres = 6;
                t = 'full';
            elseif params == 2
                ncentres = 12;
                t = 'diag';
            else
                error('doCompileOccurenceGMM: params %d unsupported!', params);
            end

            % Set up mixture model
            mix = gmm(3, ncentres, t);

            % Initialize the model parameters from the data
            options = foptions;
            options(1) = 0;
            options(14) = 50;	% Use 50 iterations of k-means in initialization
            mix = gmminit(mix, pixels(pxInd,:), options);

            % Options for EM
            options = zeros(1, 18);
            options(1) = 0;
            options(2) = 1e-1;
            options(3) = 1e-1;
            options(14) = 1000;	% Use up to 1000 iterations for EM to leave time for convergence

            % Run EM and fit mixtures
            mix = gmmem(mix, pixels(pxInd,:), options);
            histoGMM{i} = mix;
        end
    catch
        err = lasterror;
        if isfield(err, 'stack')
            line = err.stack(1).line;
            file = err.stack(1).file;
        else
            line = 0;
            file = '';
        end
        errMessage = sprintf('Processing of bin %d failed:\n\t %s \n\t at line %d of file %s ', i, err.message, line, file);
        warning(errMessage);
        fprintf(fid, errMessage);
    end
end

fclose(fid);

fprintf('done!\n');
save(fullfile(outputBasePath, sprintf('histo%s_%s_GMM.mat', colorSpaces{type}, paramsType{params})), 'histoGMM');

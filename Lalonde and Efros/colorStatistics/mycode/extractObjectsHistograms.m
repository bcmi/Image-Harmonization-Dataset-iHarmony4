%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function extractObjectsHistograms
%   Retrieve all the objects in our database and store their image and
%   object indices in a long vector. Objects must occupy between 5% and 60%
%   of the image area to be considered. Store their marginal and pairwise 
%   histograms.
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function extractObjectsHistograms 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath ../database;
addpath ../histogram;
addpath ../../3rd_party/color;
addpath ../../3rd_party/LabelMeToolbox;

% define the input and output paths
imagesBasePath = '/nfs/hn21/projects/labelme/Images/';
annotationsBasePath = '/nfs/hn21/projects/labelme/Annotation/';
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/testDataSemantic/';
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/dataSet/';

nbBinsMarginal = 100;
nbBinsJoint = 20;

% object to paste must occupy between 5% and 60% of the image
minAreaRatio = 0.05;
maxAreaRatio = 0.6;

%% Load the database
% D = LMdatabase(annotationsBasePath, subDirs);
fprintf('Loading the database...');
load(fullfile(dbPath, 'db.mat'));
fprintf('done!\n');

% load the previously extracted objects
fprintf('Loading the objects...');
load(fullfile(dbPath, 'maskInfo.mat'));
fprintf('done!\n');

%% Define color spaces
colorSpaces = {'lab', 'rgb', 'hsv'};

for c=1:length(colorSpaces)
    if strcmp(colorSpaces{c}, 'lab')
        % convert the image to the L*a*b* color space (if asked by the user)
        % L = [0 100]
        % a = [-100 100]
        % b = [-100 100]
        mins{c} = [0 -100 -100];
        maxs{c} = [100 100 100];
        type{c} = 1;

    elseif strcmp(colorSpaces{c}, 'rgb')
        mins{c} = [0 0 0];
        maxs{c} = [255 255 255];
        type{c} = 2;

    elseif strcmp(colorSpaces{c}, 'hsv')
        mins{c} = [0 0 0];
        maxs{c} = [1 1 1];
        type{c} = 3;
    else
        error('Color Space %s unsupported!', colorSpaces{c});
    end
end

%% Initialize vectors
nbObjects = accObjects - 1;
% imgIndVec = zeros(nbObjects, 1);
% objIndVec = zeros(nbObjects, 1);

accObjects = [];
for c=1:length(colorSpaces)
    marginalVec{c} = zeros(nbObjects, nbBinsMarginal, 3, 'single');
    jointVec{c} = zeros(nbObjects, nbBinsJoint, nbBinsJoint, nbBinsJoint, 'single');
    accObjects{c} = 0;
end

%% loop over all images
imgIdx = unique(imgIndVec(1:nbObjects));
N = length(imgIdx);

% accObjects = 0;
for i = 1:N
    tic;
    imgInd = imgIdx(i);
    curAnnotation = D(imgInd).annotation;

    imgOrig = imread(fullfile(imagesBasePath, curAnnotation.folder, curAnnotation.filename));
    [hSrc,wSrc,c] = size(imgOrig);
    imgOrig = imresize(imgOrig, [256 256]);
    imgArea = 256*256;

    % loop over all color spaces
    for c=1:length(colorSpaces)
        if type{c} == 1
            imgColor = rgb2lab(imgOrig);
        elseif type{c} == 2
            imgColor = imgOrig;
        elseif type{c} == 3
            imgColor = rgb2hsv(imgOrig);
        end

        imgVecColor = reshape(imgColor, 256*256, 3);

        for objInd=1:length(curAnnotation.object);
            [xPoly, yPoly] = getLMpolygon(curAnnotation.object(objInd).polygon);
            objPoly = [xPoly yPoly]';
            % I know this is stupid, but it is to replicate the same
            % conditions as in extractObjectsMasks
            objMask = poly2mask(objPoly(1,:), objPoly(2,:), hSrc, wSrc);
            areaObj = nnz(objMask) / (wSrc*hSrc);
                                   
            objPoly = objPoly .* repmat(([256 256]' ./ [wSrc hSrc]'), 1, size(objPoly, 2));
            objMask = poly2mask(objPoly(1,:), objPoly(2,:), 256, 256);
            
            if areaObj > minAreaRatio && areaObj < maxAreaRatio
                accObjects{c} = accObjects{c} + 1;

                % select the object index for generating the test image
                objIndVec(accObjects{c}) = objInd;
                imgIndVec(accObjects{c}) = imgInd;

                % compute the joint and the marginal
                indObj = find(objMask);

                for t=1:3
                    histMarginal = myHistoND(imgVecColor(indObj,t), nbBinsMarginal, mins{c}(t), maxs{c}(t));
                    histMarginal = histMarginal ./ sum(histMarginal(:));

                    marginalVec{c}(accObjects{c}, :, t) = single(histMarginal);
                end
                histJoint = myHistoND(imgVecColor(indObj,:), nbBinsJoint, mins{c}, maxs{c});
                histJoint = histJoint ./ sum(histJoint(:));

                jointVec{c}(accObjects{c}, :, :, :) = single(histJoint);
            end
        end
    end
    ti=toc;
    fprintf('%d(%d),[%0.2fs]. ', accObjects{1}, i, ti);
end
fprintf('done!\n');
fprintf('Accumulated %d masks\n', accObjects{1});

save(fullfile(dbPath, 'histogramsInfo.mat'), 'marginalVec', 'jointVec');

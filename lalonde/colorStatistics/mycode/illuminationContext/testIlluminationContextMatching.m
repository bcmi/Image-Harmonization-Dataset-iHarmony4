% function testIlluminationContextMatching
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup paths and load image
addpath ../;
setPath;

colors = {'lab', 'hsv', 'rgb', 'lalphabeta'};
types = {'sky', 'ground', 'vertical'};
% types = {'sky', 'ground'};
% types = {'sky'};

origImagesPath = '/nfs/hn21/projects/labelmeSubsampled/Images';

basePath = '/nfs/hn01/jlalonde/results/colorStatistics';
distancesPath = fullfile(basePath, 'illuminationContext', 'distances');
maskDistancesPath = fullfile(basePath, 'illuminationContext', 'distancesMasks');
dbBasePath = fullfile(basePath, 'dataset', 'combinedDb');
popupBasePath = fullfile(basePath, 'dataset', 'combinedDbPopup');

dbPath = fullfile(dbBasePath, 'Annotation');
imagesPath = fullfile(dbBasePath, 'Images');

% filename = 'image_000874';
% filename = 'image_000072';
% filename = 'image_000089';
% filename = 'image_000118';
% filename = 'image_000150';
% filename = 'image_000115';
filename = 'image_001926';
% filename = 'image_003961'; % sky is not detected correctly
% filename = 'image_002289'; % good
% filename = 'image_002487';
% filename = 'image_000963';


xmlPath = fullfile(dbPath, sprintf('%s.xml', filename));
imgPath = fullfile(imagesPath, sprintf('%s.jpg', filename));

imgInfo = loadXML(xmlPath);
img = imread(imgPath);

xmlPopupPath = fullfile(popupBasePath, imgInfo.file.folder, imgInfo.file.filename);
imgPopupInfo = loadXML(xmlPopupPath);

%% Load the image database
fprintf('Loading the image database...');
% load(fullfile(basePath, 'imageDb', 'imageDb.mat'));
fprintf('done.\n');

%% Compute the weights
load(fullfile(distancesPath, 'weights.mat'));
% fprintf('Computing the weights...\n');
% for c=1:length(colors)
%     for t=1:length(types)
%         fprintf('%s, %s...', types{t}, colors{c});
%         load(fullfile(basePath, 'illuminationContext', 'concatHistograms', sprintf('concatHisto_%s_%s.mat', types{t}, colors{c})));
% 
%         % Compute the weights for each image
%         if c == 1 || c == 4
%             fprintf('joint...');
%             w.(types{t}).(colors{c}).weightsJoint = zeros(1, length(globAccHistoJoint));
%             indValidJoint = cellfun(@(x) ~isempty(x), globAccHistoJoint);
%             weights = cellfun(@(x) sum(full(x(:))), globAccHistoJoint(indValidJoint));
%             w.(types{t}).(colors{c}).weightsJoint(indValidJoint) = weights;
%         end
% 
%         fprintf('marginals...');
%         w.(types{t}).(colors{c}).weightsMarg = zeros(size(globAccHistoMarginals, 1), 3);
%         for d=1:3
%             indValidMarg = cellfun(@(x) ~isempty(x), globAccHistoMarginals(:,d));
%             weights = cellfun(@(x) sum(full(x(:))), globAccHistoMarginals(indValidMarg,d));
%             w.(types{t}).(colors{c}).weightsMarg(indValidJoint,d) = weights;
%         end
%         fprintf('\n');
%     end
% end
% fprintf('done.\n');

%% Compute the weighted distances, compute nearest neighbors
% Number of NN
K = 55;

for c=1
    weightedDistMarg = zeros(1, length(imageDb));
    weightedDistJoint = zeros(1, length(imageDb));
    
    % store the weights (for normalization)
    imgWeight = zeros(3, 1); % one for each type
    
    color = colors{c};

    for t=1:length(types)
        type = types{t};

        xmlDistPath = fullfile(distancesPath, sprintf('%s_%s', type, color), imgInfo.file.folder, imgInfo.file.filename);
        imgDistInfo = loadXML(xmlDistPath);

        % Try the joint
        if isfield(imgDistInfo.distances.(type).(color), 'joint')
            distJointPath = fullfile(distancesPath, sprintf('%s_%s', type, color), imgInfo.file.folder, imgDistInfo.distances.(type).(color).joint.filename);
            load(distJointPath);

            % also load the corresponding histogram to get the weight
            histJointPath = fullfile(popupBasePath, imgPopupInfo.file.folder, imgPopupInfo.illContext(c).(type).joint.filename);
            load(histJointPath);
            imgWeight(t) = sum(histoJoint(:));

            if t == 1 || t == 2
%                 weightedDistJoint = weightedDistJoint + imgWeight(t) .* distancesJoint .* w.(type).(color).weightsJoint;
%                 weightedDistJoint = weightedDistJoint + distancesJoint .* w.(type).(color).weightsJoint;
                weightedDistJoint = weightedDistJoint + imgWeight(t) .* distancesJoint;
%                 weightedDistJoint = distancesJoint;
            end
        end
    end
    
    % joint
    if c == 1 || c == 4
        % normalize
%         den = zeros(1, length(imageDb));
%         for t=1:length(types)
%             if t==1 || t==2
%                 den = den + w.(types{t}).(color).weightsJoint .* imgWeight(t);
%                 den = den + w.(types{t}).(color).weightsJoint;
%                 den = den + imgWeight(t);
%             end
%         end
        den = sum(imgWeight(1:2));
        weightedDistJoint = weightedDistJoint ./ den;
        
        % keep only images with similar geometric layout
        maskDist = zeros(1, length(imageDb));
        for t=1:length(types)
            xmlMaskPath = fullfile(maskDistancesPath, types{t}, imgInfo.file.folder, imgInfo.file.filename);
            imgMaskInfo = loadXML(xmlMaskPath);
            load(fullfile(maskDistancesPath, types{t}, imgInfo.file.folder, imgMaskInfo.distances.(types{t})));
            maskDist = maskDist + imgWeight(t) .* distances;
%             maskDist = maskDist + distances;
        end
        % normalize
        maskDist = maskDist ./ sum(imgWeight);
%         maskDist = maskDist ./ length(types);
        [sortedDistMask, sortedIndMask] = sort(maskDist);
        sortedIndMask = sortedIndMask(sortedDistMask >= 0);
        sortedDistMask = sortedDistMask(sortedDistMask >= 0);
        
        threshDistMask = 0.1;
        distMin = sortedDistMask(floor(length(imageDb) * threshDistMask));
        indGoodMask = sortedIndMask(sortedDistMask <= distMin);
        
        % keep only those with similar ratios
%         totWeights = [w.sky.lab.weightsJoint; w.ground.lab.weightsJoint; w.vertical.lab.weightsJoint];
%         imgWeightNorm = imgWeight ./ sum(imgWeight);
%         totWeightsNorm = totWeights ./ repmat(sum(totWeights), 3, 1);
%         diff=abs(repmat(imgWeightNorm, 1, length(imageDb)) - totWeightsNorm);
%         
%         threshRatio = 0.1;
%         indRatio = find(diff(1,:) < threshRatio & diff(2,:) < threshRatio & diff(3,:) < threshRatio);
% %         indRatio = 1:length(diff);
%         
        indGood = indGoodMask;

        % sort the weighted distances
        [sortedDist, sortedInd] = sort(weightedDistJoint(indGood));

        % keep only the non-negative distances
        sortedInd = sortedInd(sortedDist >= 0);
        
        displayNearestNeighborsMontage(imageDb, origImagesPath, img, indGood(sortedInd), K, ...
            sprintf('%s: Weighted geometric layout + sky-ground color %s', filename, color), ...
            sprintf('%s_whtGeometricLayout_skyGround_%s.jpg', filename, color));
    end
end



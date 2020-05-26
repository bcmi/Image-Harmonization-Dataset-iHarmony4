%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnEvaluateMatchingBgNNTextons
%   Evaluate the matching of a test image based on the chi-square distance
%   between the pasted object's original image background and the target
%   image background's histograms. Uses textons histogram distance
% 
% Input parameters:
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
function dbFnEvaluateMatchingBgNNTextons(annotation, dbPath, outputBasePath, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize
addpath ../../3rd_party/parseArgs;
addpath ../../3rd_party/color;
addpath ../../3rd_party/LabelMeToolbox/;
addpath ../database;
addpath ../histogram;
addpath ../xml;

% read arguments
defaultArgs = struct('HistoImg', [], 'HistoBg', [], 'HistoObj', [], ...
    'IndObj', [], 'IndImg', [], 'TrainingDb', [], 'IndImgGlob', []);
args = parseargs(defaultArgs, varargin{:});

[pathstr, fileName, ext, versn] = fileparts(annotation.image.filename);
xmlPath = fullfile(outputBasePath, sprintf('%s.xml', fileName));
if exist(xmlPath, 'file')
    imgInfo = readStructFromXML(xmlPath);
else
    imgInfo.image = annotation.image;
end

type = 1; % Always in LAB colorspace
fracScore = 0.95;

% Load the pre-computed texton histogram
load(fullfile(dbPath, annotation.image.folder, annotation.colorStatisticsTextons5x5ObjBgUnsorted.file));
totNbObjects = size(args.HistoObj, 1);
 
% find the closest object
distChiVec = zeros(totNbObjects, 1);
distDotVec = zeros(totNbObjects, 1);
for i=1:totNbObjects
    distChiVec(i) = chisq(textonHistObj, args.HistoObj(i,:));
    distDotVec(i) = dot(textonHistObj, args.HistoObj(i,:));
end

[sortedDistChi, indChi] = sort(distChiVec);
[sortedDistDot, indDot] = sort(distDotVec, 'descend');

% keep the first 95% of distances
indChiSorted = find(sortedDistChi <= 1-((1-sortedDistChi(2))*fracScore));
indDotSorted = find(sortedDistDot >= sortedDistDot(2)*fracScore);

indChiSorted = indChiSorted(2:end);
indDotSorted = indDotSorted(2:end);

% compute the distance to the background of the corresponding object
distChiBg = zeros(1, length(indChiSorted));
for i=1:length(indChiSorted)
    distChiBg(i) = chisq(textonHistBg, full(args.HistoBg(indChi(indChiSorted(i)),:)));
end

% compute the distance to the background of the corresponding object
distDotBg = zeros(1, length(indDotSorted));
for i=1:length(indDotSorted)
    distDotBg(i) = dot(textonHistBg, args.HistoObj(indDot(indDotSorted(i)),:));
end

[minDistChi, indMinChi] = min(distChiBg);
indMinChi = indChi(indChiSorted(indMinChi));

[maxDistDot, indMaxDot] = max(distDotBg);
indMaxDot = indDot(indDotSorted(indMaxDot));

% update the xml information
imgInfo.colorStatistics(type).matchingEvaluationHistoBgNNTextons.chi.dist = minDistChi;
imgInfo.colorStatistics(type).matchingEvaluationHistoBgNNTextons.chi.indObj = args.IndObj(indMinChi);
imgInfo.colorStatistics(type).matchingEvaluationHistoBgNNTextons.chi.indImg = args.IndImg(indMinChi);
imgInfo.colorStatistics(type).matchingEvaluationHistoBgNNTextons.chi.filename = args.TrainingDb(args.IndImgGlob(indMinChi)).document.image.filename;
imgInfo.colorStatistics(type).matchingEvaluationHistoBgNNTextons.chi.folder = args.TrainingDb(args.IndImgGlob(indMinChi)).document.image.folder;

imgInfo.colorStatistics(type).matchingEvaluationHistoBgNNTextons.dot.distDot = maxDistDot;
imgInfo.colorStatistics(type).matchingEvaluationHistoBgNNTextons.dot.indObj = args.IndObj(indMaxDot);
imgInfo.colorStatistics(type).matchingEvaluationHistoBgNNTextons.dot.indImg = args.IndImg(indMaxDot);
imgInfo.colorStatistics(type).matchingEvaluationHistoBgNNTextons.dot.filename = args.TrainingDb(args.IndImgGlob(indMaxDot)).document.image.filename;
imgInfo.colorStatistics(type).matchingEvaluationHistoBgNNTextons.dot.folder = args.TrainingDb(args.IndImgGlob(indMaxDot)).document.image.folder;
    
%% Save the xml to disk
fprintf('Saving xml file: %s\n', xmlPath);
writeStructToXML(imgInfo, xmlPath);
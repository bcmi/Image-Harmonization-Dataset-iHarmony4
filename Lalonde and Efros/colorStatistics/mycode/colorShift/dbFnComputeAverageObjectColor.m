%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnComputeAverageObjectColor
%  
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r=dbFnComputeAverageObjectColor(outputBasePath, annotation, varargin) %#ok
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global globAccHisto;
r=0;

% check if the user specified the option to relabel
defaultArgs = struct('ImagesPath', [], 'NbBins', 0);
args = parseargs(defaultArgs, varargin{:});

% Load the image
imgPath = fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename);
img = imread(imgPath);
[h,w,c] = size(img);

% Get the polygon and resize it to fit the new image size
polygon = getPoly(annotation.object.polygon);
objMask = poly2mask(polygon(:,1), polygon(:,2), h, w);

imgLab = rgb2lab(img);
imgLabVec = reshape(imgLab, [w*h c]);

% Compute the 3-D histogram of the object's colors
objHisto = myHistoND(imgLabVec(objMask(:), :), args.NbBins, [0 -100 -100], [100 100 100]);

% normalize the object histogram wrt the total number of pixels in the object
globAccHisto = globAccHisto + objHisto ./ nnz(objMask);



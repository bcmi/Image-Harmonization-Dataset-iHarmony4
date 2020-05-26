%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnRecolorizeImages(imgPath, imagesBasePath, outputBasePath, annotation, varargin)
%   Re-colorizes an image from its expected color distribution
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
function dbFnRecolorizeImages(annotation, dbPath, outputBasePath, varargin)%%
% load tmp.mat;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize
addpath ../../3rd_party/parseArgs;
addpath ../../3rd_party/color;
addpath ../../3rd_party/LabelMeToolbox/;
addpath ../../3rd_party/vgg_matlab/vgg_general;
addpath ../database;
addpath ../histogram;
addpath ../xml;

% read arguments
defaultArgs = struct('Recompute', 1, 'ColorSpace', 'rgb', 'Histo1stOrder', [], 'Histo2ndOrder', [], ...
    'NbColors', []);
args = parseargs(defaultArgs, varargin{:});

% read the image and the xml information
[pathstr, fileName, ext, versn] = fileparts(annotation.image.filename);
imgPath = fullfile(dbPath, annotation.image.folder, annotation.image.filename);
origImg = imread(imgPath);

%% Recolor the image
h = recolorImageFromPalette(origImg, annotation, args.NbColors, args.Histo1stOrder, args.Histo2ndOrder, args.ColorSpace);
img = get(h, 'CData');

%% Save the resulting montage to disk
outputPath = fullfile(outputBasePath, annotation.image.folder, args.ColorSpace, pathstr);
[d,d,d] = mkdir(outputPath);

% saveas(h, fullfile(outputBasePath, annotation.image.folder, args.ColorSpace, annotation.image.filename));
imwrite(img, fullfile(outputBasePath, annotation.image.folder, args.ColorSpace, annotation.image.filename));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnEvaluateIlluminationContext`(outputBasePath, annotation, varargin)
%  
% 
% Input parameters:
%
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = dbFnEvaluateIlluminationContext(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r = 0;  

% check if the user specified the option to relabel
defaultArgs = struct('ImagesPath', [], 'SyntheticImagesPath', [], 'ImageDbPath', []);
args = parseargs(defaultArgs, varargin{:});

xmlPath = fullfile(outputBasePath, annotation.image.folder, annotation.file.filename);

% read the original images (background and object)
origBgImgPath = fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename);
origBgImg = imread(origBgImgPath);
[hB,wB,cB] = size(origBgImg); %#ok

origObjImgPath = fullfile(args.ImagesPath, annotation.imageSrc.folder, annotation.imageSrc.filename);
origObjImg = imread(origObjImgPath);
[hO,wO,cO] = size(origObjImg); %#ok

% read the imageDb annotation corresponding to the backgroud and the object (for texton output)
origBgImgInfo = loadXML(fullfile(args.ImageDbPath, strrep(annotation.image.filename, '.jpg', '.xml')));
origObjImgInfo = loadXML(fullfile(args.ImageDbPath, strrep(annotation.imageSrc.filename, '.jpg', '.xml')));

% compute the object's texton distribution
objTextonMap = load(origObjImgInfo.document);



% get the information for the closest images based on illumination matching








% build the output .mat file path
[path, baseFileName] = fileparts(annotation.image.filename);
texSubDir = 'textonMap';
texName = fullfile(texSubDir, sprintf('%s_textonMap.mat', baseFileName));

texDir = fullfile(outputBasePath, annotation.image.folder);
[s,s,s] = mkdir(fullfile(texDir, texSubDir)); %#ok

% save the filtered pixels in the corresponding .mat file
fprintf('Saving filtered pixels: %s\n', fullfile(texDir, texName));
save(fullfile(texDir, texName), 'textonMap');

% save xml information
imgInfo.univTextons.textonMap = texName;

% save the file (overwrite)
fprintf('Saving xml file: %s\n', xmlPath);
writeXML(xmlPath, imgInfo);
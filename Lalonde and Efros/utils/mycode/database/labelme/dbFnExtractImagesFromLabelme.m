%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnExtractImagesFromLabelme(outputBasePath, annotation, varargin)
%  Extracts all the objects segmented from the images.
% 
% Input parameters:
%
% Output parameters:
%   
%
% Notes:
%   - Uses the writeXML function from the labelme toolbox because it enables faster reading
%     of input files
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res=dbFnExtractImagesFromLabelme(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
res=0;

% check if the user specified the option to relabel
defaultArgs = struct('ImagesPath', [], 'HighResImagesPath', []);
args = parseargs(defaultArgs, varargin{:});

% build the xml path
xmlBasePath = fullfile(outputBasePath, annotation.folder);
[d,d,d] = mkdir(xmlBasePath); %#ok
setPermissions(xmlBasePath);
xmlPath = strrep(fullfile(xmlBasePath, annotation.filename), '.jpg', '.xml');

imgInfo.file.filename = strrep(annotation.filename, '.jpg', '.xml');
imgInfo.file.folder = annotation.folder;

imgInfo.image.filename = annotation.filename;
imgInfo.image.folder = annotation.folder;

% save the size of current and original images
[h,w,c] = size(imread(fullfile(args.ImagesPath, annotation.folder, annotation.filename))); %#ok
imgInfo.image.size.width = w;
imgInfo.image.size.height = h;

[hO,wO,cO] = size(imread(fullfile(args.HighResImagesPath, annotation.folder, annotation.filename))); %#ok
imgInfo.image.origSize.width = wO;
imgInfo.image.origSize.height = hO;

% save the file (overwrite), use attributes.
%fprintf('Saving xml file: %s\n', xmlPath);
useAttribs = 1;
write_xml(xmlPath, imgInfo, useAttribs);

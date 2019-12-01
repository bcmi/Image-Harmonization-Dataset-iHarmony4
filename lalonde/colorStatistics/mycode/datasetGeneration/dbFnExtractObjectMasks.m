%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function 
%  
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dbFnExtractObjectMasks(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check if the user specified the option to relabel
defaultArgs = struct('ImagesPath', [], 'ImageSize', 0);
args = parseargs(defaultArgs, varargin{:});

% Extract the filename
[path, name] = fileparts(annotation.image.filename);
filename = sprintf('%s_%04d.jpg', name, str2double(annotation.object.objectId));

% Load the image
imgPath = fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename);
img = imread(imgPath);
[h,w,c] = size(img);

% Get the polygon and resize it to fit the new image size
polygon = getPoly(annotation.object.polygon);
polygon = polygon .* repmat([args.ImageSize / w, args.ImageSize / h], size(polygon, 1), 1);

mask = poly2mask(polygon(:,1), polygon(:,2), args.ImageSize, args.ImageSize);

% Now shift the mask so that the polygon's bounding box is centered
center = min(polygon) + (max(polygon) - min(polygon))./2;
shift = [args.ImageSize/2 args.ImageSize/2] - center;
mask = circshift(mask, fix([shift(2) shift(1)]));

% figure(1); imshow(mask); drawnow;

% Finally, save the mask to file and also save its information in the xml file
maskSubDir = 'transMask';
maskName = strrep(filename, '.jpg', '.mat');
maskDir = fullfile(outputBasePath, annotation.image.folder, maskSubDir);
[s,s,s] = mkdir(maskDir); %#ok 

maskFilename = fullfile(maskDir, maskName);
save(maskFilename, 'mask');

annotation.mask.transMask.filename = fullfile(maskSubDir, maskName);
annotation.mask.transMask.size.width = args.ImageSize;
annotation.mask.transMask.size.height = args.ImageSize;

xmlPath = fullfile(outputBasePath, annotation.image.folder, strrep(filename, '.jpg', '.xml'));

fprintf('Saving XML %s...\n', xmlPath);
writeXML(xmlPath, annotation);

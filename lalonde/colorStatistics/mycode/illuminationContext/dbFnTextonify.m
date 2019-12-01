%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnTextonify(outputBasePath, annotation, varargin)
%  
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = dbFnTextonify(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r = 0;  

% check if the user specified the option to relabel
defaultArgs = struct('Recompute', 0, 'ImagesPath', [], 'FilterBank', [], 'FilterBankParams', [], ...
    'ClusterCenters', []);
args = parseargs(defaultArgs, varargin{:});

% load the output xml structure
xmlPath = fullfile(outputBasePath, annotation.image.folder, strrep(annotation.image.filename, '.jpg', '.xml'));
imgInfo = loadXML(xmlPath);

if ~args.Recompute && isfield(imgInfo, 'univTextons')
    fprintf('Results already computed! Skipping...\n');
end

% read the image
imgPath = fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename);
img = imread(imgPath);
[h,w,c] = size(img); %#ok

textonMap = textonify(img, args.FilterBank, args.ClusterCenters);

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


function [img, imgInfo, doRecompute, xmlPath] = readImageInfo(imgPath, outputBasePath, annotation, field, doRecompute) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create the directory if it doesn't exist
[a,b,c]=mkdir([outputBasePath annotation.folder]);

% build the xml name
xmlPath = [outputBasePath annotation.folder '/' annotation.filename];
[pathstr, name, ext, versn] = fileparts(xmlPath);
xmlPath = fullfile(pathstr, [name '.xml']);
% xmlPath = strrep(xmlPath, '.jpg', '.xml');

% if the file exists, read the xml structure
if exist(xmlPath, 'file')
    imgInfo = readStructFromXML(xmlPath);
    
    if isfield(imgInfo, field)
        % if the user did not ask to relabel, we're done!
        if doRecompute == 0
            % set to empty values, and return
            img = []; doRecompute = 0;
            return;
        end
    end
end

% open the image only if the file does not exist
img = [];

if ~exist(xmlPath, 'file')
    img = imread(imgPath);
    
    % otherwise, create an empty structure
    imgInfo.image.filename = annotation.filename;
    imgInfo.image.folder = annotation.folder;
    imgInfo.image.size.width = sprintf('%d', size(img, 2));
    imgInfo.image.size.height = sprintf('%d', size(img, 1));
end

% Sanity check: make sure the size is consistent
% width = sscanf(imgInfo.image.size.width, '%d');
% height = sscanf(imgInfo.image.size.height, '%d');
% if width ~= size(img, 2) || height ~= size(img, 1)
%     error('Image size inconsistent with the xml data');
% end

% tell the caller that we need to compute whatever it is asked
doRecompute = 1;

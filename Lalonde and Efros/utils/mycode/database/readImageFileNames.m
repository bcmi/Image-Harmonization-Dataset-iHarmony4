%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function fileList = readImageFileNames(basePath, subDirs)
%  Reads all the image files from a base directory and a list of
%  sub-directories
% 
% Input parameters:
%   - basePath: location of the top-level images directory. 
%   - subDirs: sub-directory to process. '*' will process everything
%
% Output parameters:
%   - fileList: list of image file found. It is a structure with the
%   following fields:
%     - filename: name (with extension) of the file
%     - folder: name of the folder in which it was found
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fileList = readImageFileNames(basePath, subDirs) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read all images in the subdirectories
if strcmp(subDirs, '*')
    % read the directories in the input directory
    files = dir(basePath);
    
    subDirs = [];
    for j=1:length(files)
        if files(j).isdir && ~strcmp(files(j).name, '.') && ~strcmp(files(j).name, '..')
            subDirs{length(subDirs)+1} = files(j).name;
        end
    end
end

fileList = [];
for i=1:length(subDirs)
    files = dir(fullfile(basePath, subDirs{i}));
    
    for j=3:length(files)
        % make sure it's an image file
        [pathstr, name, ext, versn] = fileparts(files(j).name);
        
        if strcmp(ext, '.png') || strcmp(ext, '.PGN') || strcmp(ext, '.jpg') || strcmp(ext, '.JPG') || strcmp(ext, '.bmp') || strcmp(ext, '.BMP')
            fileList(length(fileList)+1).filename = files(j).name;
            fileList(length(fileList)).folder = subDirs{i};
        else
            fprintf('Unknown file extension: %s\n', files(j).name);
        end
    end
end

function files = getfilenames(path, pattern, fullpath, recurse)
% Return cell array of files matching the pattern at the specified path.
% 
%   files = getfilenames(basePath, <pattern>, <fullpath>, <recurse>)
%
%   'pattern': pattern to be matched. The special case of 'images' will find 
%   all image types in the input directory.
% 
%   'fullpath': boolean (defaults to false). When 'true', returns the full
%   path for each file.
%
%   'recurse': integer which specifies the number of times we have to
%   recurse into sub-directories. Set to 'Inf' to recurse the entire
%   directory tree.
%   
% 
% ----------
% Jean-Francois Lalonde

if nargin < 2
    pattern = '';
end

if nargin < 3
    fullpath = false;
end

if nargin < 4
    recurse = false;
end

files = {};
if recurse > 0
    % look for directories
    dirs = getdirnames(path, '', true);
    
    for i_dir = 1:length(dirs)
        subFiles = getfilenames(dirs{i_dir}, pattern, fullpath, recurse-1);
        files = cat(2, files, subFiles);
    end
end

% special case: when 'pattern' is 'images', look for all types of images
if strcmp(pattern, 'images')
    curFiles = dir(fullfile(path));
    dirInd = [curFiles(:).isdir];
    curFiles = {curFiles(~dirInd).name};
    
    % TODO: add more here, as needed!
    imgExt = {'.jpg', '.jpeg', '.tif', '.tiff', '.png', '.exr'};
    
    validInd = false(size(curFiles));
    for i_ext = 1:length(imgExt)
        validInd = validInd | ...
            ~cellfun(@isempty, strfind(lower(curFiles), imgExt{i_ext}));
    end
    
    curFiles = curFiles(validInd);
    
else
    curFiles = dir(fullfile(path, pattern));
    dirInd = [curFiles(:).isdir];
    curFiles = {curFiles(~dirInd).name};
end


% remove hidden files
hiddenFilesInd = cellfun(@(x) x(1)=='.', curFiles);
curFiles(hiddenFilesInd) = [];

% concatenate full path to each file
if fullpath
    curFiles = fullfile(path, curFiles);
end

% add to existing list of files
files = cat(2, files, curFiles);
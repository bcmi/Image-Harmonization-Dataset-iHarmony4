function dirs = getdirnames(path, pattern, fullpath, recurse)
% Return cell array of directories matching the pattern at the specified path.
% 
%   files = getdirnames(basePath, pattern, fullpath, recurse)
%
%   'pattern': pattern to be matched. 
% 
%   'fullpath': boolean (defaults to false). When 'true', returns the full
%   path for each file.
%
%   'recurse': integer which specifies the number of times we have to
%   recurse into sub-directories.
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
    recurse = 0;
end

dirs = dir(fullfile(path, pattern));
dirInd = [dirs(:).isdir];
dirs = {dirs(dirInd).name};

% remove hidden directories
hiddenFilesInd = cellfun(@(x) x(1)=='.', dirs);
dirs(hiddenFilesInd) = [];

% concatenate full path to each file
if fullpath
    dirs = fullfile(path, dirs);
end

if recurse > 0
    allDirs = {};
    for i_d = 1:length(dirs)
        curDir = dirs{i_d};
        if ~fullpath
            curDir = fullfile(path, curDir);
        end
        allDirs = cat(2, allDirs, ...
            getdirnames(curDir, pattern, fullpath, recurse-1));
    end
    dirs = allDirs;
end
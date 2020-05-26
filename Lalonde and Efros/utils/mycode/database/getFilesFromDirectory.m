%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [files, directories] = getFilesFromDirectory(basePath, subPath, includeStrings, excludeStrings, extension, recurse)
%   Gets a list of all the files inside a directory.
% 
% Input parameters:
%   - basePath: path to the database
%   - subPath: subpath to search
%   - includeStrings: strings that must be present in the file name
%   - excludeStrings: strings that must not be present in the file name
%
% Output parameters:
%   - files: cell array of the filenames found in that directory.
%   - directories: cell array of corresonding directories
%
% Warning:
%   New implementation requires the command find (under linux)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [files, directories] = getFilesFromDirectory(basePath, subPath, includeStrings, excludeStrings, extension, recurse)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 1
    subPath = '.';
    includeStrings = [];
    excludeStrings = [];
    extension = '';
    recurse = 0;
end

if isempty(subPath)
    subPath = '.';
end

% check if call is really simple (this is much faster than find, hopefully!)
if ~recurse && isempty(excludeStrings)
    if ~isempty(strfind(basePath, 'http://'))
        % read files from URL?
        htmlStr = urlread(basePath);        
        extInd = strfind(htmlStr, sprintf('%s<', extension));
        bracketInd = strfind(htmlStr, '>');
        
        prevBracketInd = arrayfun(@(j) find((j-bracketInd) > 0, 1, 'last'), extInd);
        
        files = arrayfun(@(i,j) htmlStr(i+1:j+3), bracketInd(prevBracketInd), extInd, 'UniformOutput', 0);
    else
        files = dir(fullfile(basePath, subPath, sprintf('*%s', extension)));
        files = {files.name};
    end
    % keep only files that are in the includeStrings
    if isempty(includeStrings)
        goodInd = true(size(files));
    else
        goodInd = false(size(files));
    end
    if ~iscell(includeStrings)
        incStr{1} = includeStrings;
    else
        incStr = includeStrings;
    end
    for i=1:length(incStr)
        goodInd = goodInd | cellfun(@(f) ~isempty(strfind(f, incStr{i})), files);
    end
    files = files(goodInd);
    directories = repmat({'.'}, size(files));
    return;
end

% check if call is really simple (this is much faster than find, hopefully!)
if ~recurse && isempty(excludeStrings) && isempty(includeStrings)
    files = dir(fullfile(basePath, subPath, sprintf('*%s', extension)));
    files = {files.name};
    directories = repmat({'.'}, size(files));
    return;
end

% fprintf('Reading all files...');
% extract the list of all filenames
origPath = pwd;
cd(basePath);

if recurse
    cmd = sprintf('find %s -path ''*%s''', subPath, extension);
else
    cmd = sprintf('find %s -maxdepth 1 -mindepth 1 -path ''*%s''', subPath, extension);
end

% add strings that must be present (OR)
if iscell(includeStrings)
    cmd = sprintf('%s \\( -path ''*/%s*''', cmd, includeStrings{1});
    for i=2:length(includeStrings)
        cmd = sprintf('%s -o -path ''*/%s*''', cmd, includeStrings{i});
    end
    cmd = sprintf('%s \\)', cmd);
elseif ~isempty(includeStrings)
    cmd = sprintf('%s -path ''*/%s*''', cmd, includeStrings);
end

% add strings that must not be present (NONE of them)
if iscell(excludeStrings)
    for i=1:length(excludeStrings)
        cmd = sprintf('%s -not -name ''%s''', cmd, excludeStrings{i});
    end
elseif ~isempty(excludeStrings)
    cmd = sprintf('%s -not -name ''%s''', cmd, excludeStrings);
end

[s, r] = system(cmd);
cd(origPath);

% pre-allocate the cell arrays
nbFiles = nnz(r == 10);
files = cell(1, nbFiles);
directories = cell(1, nbFiles);

if nbFiles == 0
    return;
end

% parse each of them
str = textscan(r, '%s', nbFiles);

for i=1:length(str{1})
    [path, name, ext] = fileparts(str{1}{i});

    files{i} = sprintf('%s%s', name, ext);
    directories{i} = strrep(path, './', '');
end

% fprintf('done.\n');


% sort the filenames
[files, ind] = sort(files);
directories = directories(ind);

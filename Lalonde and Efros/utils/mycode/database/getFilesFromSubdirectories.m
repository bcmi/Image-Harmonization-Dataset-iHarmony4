%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [files, directories] = getFilesFromSubdirectories(basePath, subDirectories, extension)
%   Gets a list of all the files inside a list of subdirectories
% 
% Input parameters:
%   - databasePath: path to the database
%   - subDirectories: cell array of subdirectories to process. Can also be a pattern in a single
%   string like '*' or '*static*'.
%   - extension: extension of the files to retrieve. e.g. 'xml'
%
% Output parameters:
%   - files: cell array of the filenames found in that directory.
%   - directories: cell array of corresonding directories
%
% Warning:
%   New implementation requires the command find (under linux)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [files, directories] = getFilesFromSubdirectories(basePath, subDirectories, extension)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if ~iscell(subDirectories)
    fprintf('Reading all files...');
    % extract the list of all filenames
    origPath = pwd;
    cd(basePath);
    [s, r] = system(sprintf('find . -path ''*%s*'' -name ''*.%s''', subDirectories, extension));
%     [s, r] = system(sprintf('find . -wholename ''*%s*.%s''', subDirectories, extension));
%     [s, r] = system(sprintf('find . -name ''*.%s'' | grep %s', extension, subDirectories));
    cd(origPath);

    % pre-allocate the cell arrays
    nbFiles = nnz(r == 10);
    files = cell(1, nbFiles);
    directories = cell(1, nbFiles);

    % parse each of them
    str = textscan(r, '%s', nbFiles);

    for i=1:length(str{1})
        [path, name, ext] = fileparts(str{1}{i});

        files{i} = sprintf('%s%s', name, ext);
        directories{i} = strrep(path, './', '');
    end
    
    fprintf('done.\n');
else
    
    files = {};
    directories = {};

    % loop over all the subdirectories
    for i=1:length(subDirectories)
        fprintf(1, 'Reading files from %s... \n', subDirectories{i});
        totalDir = fullfile(basePath, subDirectories{i});

        % read all the xml files in the subdirectory
        filesSubDir = dir(fullfile(totalDir,  sprintf('*.%s', extension)));

        files = {files{:} filesSubDir(:).name};
        t = repmat({subDirectories{i}}, 1, length(filesSubDir));
        directories = {directories{:} t{:}};
    end
end

% sort the filenames
[files, ind] = sort(files);
directories = directories(ind);

function fileCell = findfiles(varargin)
%FINDFILES  Recursively search directory for files.
%   FINDFILES returns a cell array with the file names of all files
%   in the current directory and all subdirectories.
%
%   FINDFILES(DIRNAME) returns the file names of all files in the given
%   directory and its subdirectories.
%
%   FINDFILES(DIRNAME, FILESPEC) only returns the file names matching the
%   given file specification (like '*.c' or '*.m').
%
%   FINDFILES(DIRNAME, FILESPEC, 'nonrecursive') searches only in the top
%   directory.
%
%   FINDFILES(DIRNAME, FILESPEC, EXLUDEDIR1, ...) excludes the additional
%   directories from the search.
%
%		Example:
%		fileList = findfiles('.', '*.m');
%
%		Markus Buehren
%		Last modified 21.04.2008 
%
%   See also DIR.

if nargin == 0
	searchPath = '.';
	fileSpec   = '*';
elseif nargin == 1
	searchPath = varargin{1};
	fileSpec   = '*';
else
	searchPath = varargin{1};
	fileSpec   = varargin{2};
end

excludeCell = {};
searchrecursive = true;
for n=3:nargin
	if isequal(varargin{n}, 'nonrecursive')
		searchrecursive = false;
	elseif iscell(varargin{n})
 		excludeCell = [excludeCell, varargin{n}]; %#ok
	elseif ischar(varargin{n}) && isdir(varargin{n})
		excludeCell(n+1) = varargin(n); %#ok
	else
		error('Directory not existing or unknown command: %s', varargin{n});
	end
end

searchPath = chompsep(searchPath);
if strcmp(searchPath, '.')
 	searchPath = '';
elseif ~exist(searchPath, 'dir')
	error('Directory %s not existing.', searchPath);
end

% initialize cell
fileCell = {};

% search for files in current directory
dirStruct = dir(concatpath(searchPath, fileSpec));
for n=1:length(dirStruct)
	if ~dirStruct(n).isdir
		fileCell(end+1) = {concatpath(searchPath, dirStruct(n).name)}; %#ok
	end
end

% search in subdirectories
if searchrecursive
	excludeCell = [excludeCell, {'.', '..', '.svn'}];
	if isempty(searchPath)
		dirStruct = dir('.');
	else
		dirStruct = dir(searchPath);
	end
	
	for n=1:length(dirStruct)
		if dirStruct(n).isdir
			name = dirStruct(n).name;
			if ~any(strcmp(name, excludeCell))
				fileCell = [fileCell, findfiles(concatpath(searchPath, name), fileSpec)]; %#ok
			end
		end
	end
end

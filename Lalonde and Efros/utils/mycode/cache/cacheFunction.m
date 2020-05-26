function varargout = cacheFunction(fnHandle, varargin)
% Main 'caching' function.
%
% [...] = cacheFunction(fnHandle, ...)
%
% [...] = cacheFunction(fnHandle, 'hashKey', hashKey, ...)
%
%   Over-ride hash key with input one. Use at your own risk!
%
% [...] = cacheFunction(..., 'useCache', false, ...)
%
%   Disables the use of the cache (for convenience)
%
% 
% ----------
% Jean-Francois Lalonde
%

% disable the use of the cache if needed
indUseCache = find(strcmpi(varargin, 'useCache'));
if ~isempty(indUseCache)
    useCache = varargin{indUseCache+1};
    varargin(indUseCache:indUseCache+1) = [];
    
    if ~useCache
        varargout = cell(1, nargout);
        [varargout{:}] = fnHandle(varargin{:});
        return;
    end
end

% look for 'hashKey' in the inputs
indHashKey = find(strcmpi(varargin, 'hashkey'));
if ~isempty(indHashKey) && ~isempty(varargin{indHashKey+1})
    h = varargin{indHashKey+1};
    varargin(indHashKey:indHashKey+1) = [];
else
    h = hashKey(varargin{:});
end

cachePath = getPathName('results', 'cache');
cacheFile = fullfile(cachePath, func2str(fnHandle), [h '.mat']);

if exist(cacheFile, 'file')
    fprintf('Results of %s found in cache. Retrieving...\n', ...
        func2str(fnHandle)); tic;
    
    % has been cached already! just load from cache
    results = load(cacheFile);
    if nargout > length(results.results)
        error(['Function %s was cached with only %d outputs, but %d were requested. ' ...
            'Please delete the file %s \nand run again.'], ...
            func2str(fnHandle), length(results.results), nargout, cacheFile);
    end
    
    varargout = results.results(1:nargout);
else
    % has not yet been cached. compute (and store) it.
    fprintf('Not found in cache. Computing %s...', ...
        func2str(fnHandle)); tic;
    
    results = cell(1, nargout);
    [results{:}] = fnHandle(varargin{:});
    [~,~,~] = mkdir(fileparts(cacheFile));
    save(cacheFile, 'results');
    
    varargout = results;
    
    fprintf('done in %2.fs\n', toc);
end
    
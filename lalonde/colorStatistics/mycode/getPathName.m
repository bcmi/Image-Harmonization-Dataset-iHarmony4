function path = getPathName(str, varargin)
% Returns path name for the color statistics project.
%
%   path = getPathName(str, varargin)
%
%   Here, 'varargin' works as in the matlab built-in 'fullfile', i.e. it
%   concatenates other strings into paths.
%
% See also:
%   fullfile
% 
% ----------
% Jean-Francois Lalonde

% get system-dependent hostname
[d, host] = system('hostname');

if isdeployed || (~isempty(strfind(lower(host), 'cmu')) && ...
        isempty(strfind(lower(host), 'jf-mac'))) || ...
        ~isempty(strfind(lower(host), 'compute'))
    
    % at CMU
    basePath = '/nfs/hn01/jlalonde';
else
    % on my laptop
    codeBasePath = 'YOUR_PATH_TO_LALONDE_CODE';
    resultsBasePath = 'YOUR_PATH_TO_SAVE_RESULTS';
end

projectName = 'colorStatistics';

if nargin == 0 || isempty(str)
    fprintf('Options: ''code'', ''codeUtils'', ''logs''.\n');
    path = '';
else
    
    switch(str)
        case 'code'
            path = fullfile(codeBasePath, projectName);

        case 'codeUtils'
            path = fullfile(codeBasePath, 'utils');
            
        case 'codeUtilsPrivate'
            path = fullfile(codeBasePath, 'utilsPrivate');
        
        case 'logs'
            path = fullfile(resultsBasePath, 'logs');
            
        case 'results'
            path = fullfile(resultsBasePath, projectName);
            
        otherwise
            error('Invalid option');
    end

    if ~isempty(varargin)
        path = fullfile(path, varargin{:});
    end
end
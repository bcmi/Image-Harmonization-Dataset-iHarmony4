function [ret, errInd] = runFunctionOnDatabase(db, fnHandle, fnParams, varargin)
% Runs a function on an image database, with support for parallelization
%
%   [ret, errInd] = runFunctionOnDatabase(db, fnHandle, fnParams, ...)
%
% This should work "out of the box" for all databases supported by 
% getDatabaseType. To make it work on other things, say a bunch of
% filenames, create a 'generic' database like so:
%
%   db.generic = cell2struct(files, 'file', 1);
%
% where 'files' is a cell array of file names. 
%
% ----------
% Jean-Francois Lalonde

% Progress bar information
pBar = Progress();
pBarMessage = sprintf('Running %s', func2str(fnHandle));

% whether this is run locally or on other machines
local = true;

% setting this to false will disable parallelism completely!
parallel = true; 

% time it should take to run on a single image (in seconds)
maxEvalTime = 5*60;

nrOfEvalsAtOnce = 1;

% show waitbar
useWaitbar = true;

% useful for debugging
indToProcess = [];

parseVarargin(varargin{:});

if islogical(indToProcess)
    % expecting indexed vector
    indToProcess = find(indToProcess);
end

dbType = getDatabaseType(db);

pBar.push_bar(pBarMessage, 1, length(db.(dbType)));

if isempty(indToProcess)
    indToProcess = 1:length(db.(dbType));
end

ret = cell(1, length(indToProcess));
parameterCell = cell(1, length(indToProcess));

% double-check bounds
assert(max(indToProcess) <= length(db.(dbType)));

for i_db = 1:length(indToProcess)
    if ~parallel || mod(i_db, 100) == 0
        pBar.set_val(i_db);
    end
    dbInfo = getInfoFromDatabase(db, indToProcess(i_db));
    
    curParams = cat(2, {dbInfo, indToProcess(i_db)}, fnParams);
    
    if parallel
        % save the parameters
        parameterCell{i_db} = cat(2, {fnHandle}, curParams);
    else
        % run the function directly, wrapped in a try/catch statement
        ret{i_db} = runFunctionTryCatch(fnHandle, curParams{:});
    end
end
pBar.pop_bar();

if parallel
    % start the processing!
    settings = struct('multicoreDir', getPathName(local, 'slaves'), ...
        'nrOfEvalsAtOnce', nrOfEvalsAtOnce, 'useWaitbar', useWaitbar, ...
        'masterIsWorker', false, 'maxEvalTimeSingle', maxEvalTime);
    ret = startmulticoremaster(@runFunctionTryCatch, parameterCell, settings);
end

% check if there were errors caught
errInd = cellfun(@(r) isa(r, 'MException'), ret);

if any(errInd)
    warning('dbFunction:err', 'Caught %d/%d (%.2f%%) errors!', ...
        nnz(errInd), i_db, nnz(errInd)/i_db*100);
end

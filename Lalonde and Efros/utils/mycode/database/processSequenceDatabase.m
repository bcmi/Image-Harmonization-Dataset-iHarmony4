%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function processSequenceDatabase(basePath, includeStrings, excludeStrings, outputBasePath, dbFn, ...
%   parallelized, randomized, varargin)
%  Goes over the entire database (specified as input), and performs some
%  processing on each folder found.
% 
% Input parameters:
%   - basePath: base path of the image database
%   - includeStrings: string(s) that *must* be present in the file names
%   - excludeStrings: string(s) that *must not* be present in the file names (anywhere)
%   - outputBasePath: location of the top-level results directory. 
%     Will automatically create subdirectories at that location.
%   - dbFn: function to be executed on each image. Must take care of saving
%     whatever results it wants.
%   - parallelized: whether to parallelize the process or not
%   - randomized: whether to randomize the order or not
%   - extension: filename extension (e.g.: jpg) of the type of files to look for
%   - varargin: additional parameters to dbFn (application-specific)
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function processSequenceDatabase(basePath, includeStrings, excludeStrings, outputBasePath, dbFn, ...
    parallelized, randomized, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Prepare the log file, using the caller's function name
logFileId = getLogFile(2);
[r,hostname] = system('hostname -s'); hostname = hostname(1:end-1);
logAndDisplay(logFileId, 'Experiment started on %s: %s\n', hostname, datestr(now)); 

% Read all the files in the specified directory
files = getFilesFromDirectory(basePath, '', includeStrings, excludeStrings, '', 0);

% determine the order in which to loop over the database elements
if randomized
    ind = randperm(length(files));
else
    ind = 1:length(files);
end

% count the number of errors
nbErrors = 0;

% loop over all the contents of the directory
for j=ind
    seqName = files{j};
    currentPath = fullfile(basePath, seqName);
        
    try
        seqFiles = getFilesFromDirectory(currentPath, '', '', excludeStrings, '', 0);
        
        % if parallel, try to acquire lock
        if parallelized
            [gotLock, lockFile] = acquireLock(outputBasePath, '', seqName);
        else 
            gotLock = 1;
        end
        
        % skip this element if it's already locked
        if ~gotLock
            continue;
        end
        
        logAndDisplay(logFileId, sprintf('%s \n', currentPath)); 
        
        % call the database function (which should take care of saving whatever it wants)
        r = dbFn(outputBasePath, seqName, seqFiles, varargin{:});
        
        if r
            return;
        end
    catch
        err = lasterror;
        if isfield(err, 'stack')
            line = err.stack(1).line;
            file = err.stack(1).file;
        else
            line = 0;
            file = '';
        end
        errMessage = sprintf('Processing of image %s failed:\n\t %s \n\t at line %d of file %s ', fullfile(currentPath, seqName), err.message, line, file);

        % log the error message
        logAndDisplay(logFileId, '*** ERROR ***\n');
        logAndDisplay(logFileId, errMessage);
        logAndDisplay(logFileId, '\n');
        
        % delete the lock file if it exist
        if exist('lockFile', 'var')
            delete(lockFile);
        end
        
        nbErrors = nbErrors + 1;
    end
end


logAndDisplay(logFileId, 'Experiment ended at %s with %d errors\n', datestr(now), nbErrors);
fclose(logFileId);

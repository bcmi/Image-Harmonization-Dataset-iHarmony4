%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function processDatabaseFiles(files, directories, outputBasePath, dbFn,
% parallelized, randomized, topField, varargin)
%  Goes over the entire database (specified as input), and performs some
%  processing on each image found. 
% 
% Input parameters:
%   - files: list of files to process
%   - directories: list of directories to process (corresponding to files)
%   - outputBasePath: location of the top-level results directory. 
%     Will automatically create subdirectories at that location.
%   - dbFn: function to be executed on each image. Must take care of saving
%     whatever results it wants.
%   - parallelized: whether to parallelize the process or not
%   - randomized: whether to randomize the order or not
%   - varargin: additional parameters to dbFn
%       (application-specific)
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function processDatabaseFiles(basePath, files, directories, outputBasePath, dbFn, parallelized, randomized, topField, varargin)
global processDatabaseImgNumber
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Prepare the log file, using the caller's function name
logFileId = getLogFile(3);
[r,hostname] = system('hostname -s'); hostname = hostname(1:end-1);
logAndDisplay(logFileId, 'Experiment started on %s: %s\n', hostname, datestr(now)); 

% determine the order in which to loop over the database elements
if randomized
    ind = randperm(length(files));
else
    ind = 1:length(files);
end

% count the number of errors
nbErrors = 0;
count = 0;

% loop over all the database instances
for j=ind
    count = count + 1;

    try
        % load the xml file
        xmlPath = fullfile(basePath, directories{j}, files{j});
        
        % load the XML
        xml = load_xml(xmlPath);
        if isfield(xml, 'document')
            document = xml.document;
        else
            document = xml;
        end
        
        % if parallel, try to acquire lock
        if parallelized
            [gotLock, lockFile] = acquireLock(outputBasePath, directories{j}, files{j});
        else 
            gotLock = 1;
        end
        
        % skip this element if it's already locked
        if ~gotLock
            continue;
        end
        
        logAndDisplay(logFileId, '[%.3f%%] Processing %s...\n', count ./ length(ind) * 100, fullfile(directories{j}, files{j}));
        
        % set the database image number
        processDatabaseImgNumber = j;
        
        % call the database function (which should take care of saving whatever it wants)
        if ~isempty(topField)
            r = dbFn(outputBasePath, document.(topField), varargin{:});
        else
            r = dbFn(outputBasePath, document, varargin{:});
        end
        
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
        errMessage = sprintf('Processing of image %s failed:\n\t %s \n\t at line %d of file %s ', fullfile(directories{j}, files{j}), err.message, line, file);

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




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function processImageDatabaseFiles(basePath, currentPath, files, outputBasePath, dbFn, ...
%    parallelized, randomized, logFileId, varargin)
%  Recursive function that processes all the files in an image repository
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nbErrors = processDatabaseRecursiveFiles(basePath, currentPath, files, outputBasePath, dbFn, ...
    parallelized, randomized, logFileId, varargin)
% global processDatabaseImgNumber;

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

    % if the file is a directory, append the path and recurse
    if isdir(fullfile(basePath, currentPath, files{j}))
        currentPathTemp = fullfile(currentPath, files{j});
        
%         processDatabaseRecursiveFiles(basePath, currentPathTemp, files, outputBasePath, dbFn, ...
%             parallelized, randomized, logFileId, varargin{:});
        
        nbErrorsTemp = processDatabaseRecursive(basePath, currentPathTemp, '', '', ...
            outputBasePath, dbFn, parallelized, randomized, logFileId, varargin{:});
        nbErrors = nbErrors + nbErrorsTemp;
        
        continue;
        
%     elseif isempty(strfind(lower(files{j}), '.jpg')) && isempty(strfind(lower(files{j}), '.gif')) && ...
%             isempty(strfind(lower(files{j}), '.tif')) && isempty(strfind(lower(files{j}), '.bmp'))

        % not an image file: skip
        continue;
    end
    
    try
        [f,p,ext] = fileparts(files{j});
        
        % there's no xml file, so prepare a basic structure
        document.file.folder = currentPath;
        document.file.filename = strrep(files{j}, ext, '.xml');
        document.image.folder = currentPath;
        document.image.filename = files{j};
        
        % if parallel, try to acquire lock
        if parallelized
            [gotLock, lockFile] = acquireLock(outputBasePath, currentPath, files{j});
        else 
            gotLock = 1;
        end
        
        % skip this element if it's already locked
        if ~gotLock
            continue;
        end
        
        logAndDisplay(logFileId, sprintf('%s \n', fullfile(currentPath, files{j}))); 
        
        global processDatabaseImgNumber
        processDatabaseImgNumber = j;
        
        % call the database function (which should take care of saving whatever it wants)
        r = dbFn(outputBasePath, document, varargin{:});
        
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
        errMessage = sprintf('Processing of image %s failed:\n\t %s \n\t at line %d of file %s ', fullfile(currentPath, files{j}), err.message, line, file);

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



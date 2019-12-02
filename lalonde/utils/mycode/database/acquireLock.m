%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [gotLock, lockFile] = acquireLock(outputBasePath, folder, filename)
%  Obtains a lock file for a given file and folder. the gotLock variable indicates if the lock was
%  obtained successfully or if another process already got it.
% 
% Input parameters:
%   - outputBasePath: 
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [gotLock, lockFile] = acquireLock(outputBasePath, folder, filename)
global lockAppend
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% create a lock file (make sure the directory exists)
lockPath = fullfile(outputBasePath, 'Locks', folder);
[m,m,m] = mkdir(lockPath); %#ok

[pathstr,name] = fileparts(filename);
if ~isempty(lockAppend)
    name = sprintf('%s_%s', name, lockAppend);
end
lockFile = fullfile(lockPath, sprintf('%s.lock', name));

gotLock = 0;

% make sure the lock file doesn't exist
rD = round(1e9*rand);
if ~exist(lockFile, 'file')
    % write a random number
    fidLock = fopen(lockFile, 'w+');
    fwrite(fidLock, rD, 'int32');
    fseek(fidLock, 0, 'bof');
    fclose(fidLock);

    % pause for a random amount of time between 0 and 300ms
    pause(rand*0.3);
    
    fidLock = fopen(lockFile, 'r');
    rT = fread(fidLock, 1, 'int32');
    fclose(fidLock);

    % make sure we were the ones actually writing the file
    if rD == rT
        gotLock = 1;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function logFileId = getLogFile(stackLevel)
%   Creates a log file and returns its file handler.
% 
% Input parameters:
%   - stackLevel: level in the stack to use to find the application name. A stackLevel of 0 
%     represents the current function (getLogFile), 1 (default) is the direct caller, 2 is the caller's
%     caller, etc.
%
% Output parameters:
%   - logFileId: file identifier. Application must take care of closing it (with fclose)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function logFileId = getLogFile(stackLevel)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global logFileRoot;

if nargin == 0
    stackLevel = 1;
end

% automatically find the experiment number
[stack,I] = dbstack;

if stackLevel >= length(stack)
    stackLevel = length(stack)-1;
    warning('Stack level too large');
end

[s,hostname] = system('hostname -s'); hostname(end) = [];

processName = stack(I+stackLevel).name;
files = struct2cell(dir(fullfile(logFileRoot, sprintf('%s_%s_*', processName, hostname))));
processNb = 0;
if size(files,2)
    last = files{1,size(files,2)};
    processNb = sscanf(last, sprintf('%s_%s_%%04d.log', processName, hostname)) + 1;
end

logFileName = fullfile(logFileRoot, sprintf('%s_%s_%04d.log', processName, hostname, processNb));
logFileId = fopen(logFileName, 'w'); 

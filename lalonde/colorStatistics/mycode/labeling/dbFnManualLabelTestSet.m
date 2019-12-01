%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnManualLabelTestSet
%   Manually label the test set
% 
% Input parameters:
%
%   - varargin: Possible values:
%     - 'Recompute':
%       - 0: (default) will not compute the histogram when results are
%         already available. 
%       - 1: will re-compute histogram no matter what
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret=dbFnManualLabelTestSet(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check if the user specified the option to recompute
defaultArgs = struct('LabelerId', 0, 'LockPath', [], 'ImagesPath', []);
args = parseargs(defaultArgs, varargin{:});
ret = 0;

% read the xml information (if present)
xmlPath = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);
lockFile = fullfile(args.LockPath, annotation.file.folder, strrep(annotation.file.filename, '.xml', '.lock'));

%% Check if it's already labeled
nbLabelers = 0;
imgInfo = loadXML(xmlPath);

if isfield(imgInfo, 'class')
    labelers = arrayfun(@(x) str2double(x.labelerId), imgInfo.class);

    if nnz(labelers == args.LabelerId)
        fprintf('Already computed. Skipping...\n');
        delete(lockFile);
        return;
    end
    nbLabelers = length(imgInfo.class);
end

labelInd = nbLabelers + 1;
imgInfo.class(labelInd).labelerId = args.LabelerId;

imgPath = fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename);
img = imread(imgPath);
imHandle = figure(1);
imshow(img);

%% Select class
[uInput, uDescription] = askUserInput(imHandle, 'Enter class', ...
    {{'r', 'realistic'}, ...
    {'u', 'unrealistic'}, ...
    {'o', 'other'}, ...
    {'q', 'quit'}});

if strcmp(uInput, 'q')
    % delete the lock file and exit the program
    delete(lockFile);
    ret = 1; 
    fprintf('Quitting...\n');
    close;
    return;
end
fprintf('\t Image %s has been labeled as %s\n', fullfile(annotation.image.folder, annotation.image.filename), uDescription);
imgInfo.class(labelInd).type = uInput;

%% Save the xml to disk
fprintf('Saving xml file: %s\n', xmlPath);
writeXML(xmlPath, imgInfo);
% delete the lock file
delete(lockFile);

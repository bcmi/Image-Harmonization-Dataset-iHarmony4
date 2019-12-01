%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doCompileUserLabeling
%   Scripts that compiles the user-provided labelings
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doCompileUserLabeling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup paths
addpath ../;
setPath;

% define the input and output paths
labelingBasePath = fullfile(basePath, 'dataset', 'labeling');
imageBasePath = fullfile(basePath, 'dataset', 'filteredDb', 'Images');
databasesPath = fullfile(basePath, 'databases');
outputBasePath = fullfile(basePath, 'matchingEvaluation', 'compiledResults');
compiledResultsPath = fullfile(basePath, 'matchingEvaluation', 'compiledResults');
userIDs = [1 2 3];

%% Load my labelings
load(fullfile(outputBasePath, 'labelings.mat'));
labelsJeff = imageLabel(1:1808);
indJeff = labelsJeff>0;

%% Load the databases

labelings = cell(length(userIDs), 1);
for i=userIDs
    labelingPath = fullfile(labelingBasePath, sprintf('labeler_%04d', i));
    fprintf('Loading data from %s\n', labelingPath);
    labelings{find(userIDs == i)} = loadDatabaseFast(labelingPath, '');
end

%% Extract the labels
labels = zeros(length(labelings{1}), length(userIDs));

for i=userIDs
    labels(:,i) = labels(:,i) + arrayfun(@(x) double(strcmp(x.document.class.type, 'r')).*1, labelings{i})';
    labels(:,i) = labels(:,i) + arrayfun(@(x) double(strcmp(x.document.class.type, 'u')).*2, labelings{i})';
    labels(:,i) = labels(:,i) + arrayfun(@(x) double(strcmp(x.document.class.type, 'o')).*3, labelings{i})';
end

% compute the majority label
labelsMaj = zeros(length(labelings{1}), 1);

for i=1:length(labelings{1})
    % count the instances of each label
    [m,labelsMaj(i)] = max(histc(labels(i,:), 1:3));
end

%% Extract the reaction time
times = zeros(length(labelings{1}), length(userIDs));

for i=userIDs
    times(:,i) = arrayfun(@(x) str2double(x.document.class.time), labelings{i})';
end

%% Compile the labelings

% Indices of (potentially) bad images
indBad = (labels(:,1) == 3 | labels(:,2) == 3 | labels(:,3) == 3);
fprintf('%d (%.2f%%) images are labeled as bad by at least 1 labeler\n', nnz(indBad), nnz(indBad)/length(indBad)*100);

indGood = ~indBad;

% Indices of images that are labeled identically by all labelers
indAll = (labels(:,1) == labels(:,2) & labels(:,2) == labels(:,3));
indAll = indAll & indGood;
fprintf('%d (%.2f%%) of good images are labeled identically by all 3 labelers\n', nnz(indAll), nnz(indAll)/nnz(indGood)*100);
fprintf('\t(%d (%.2f%%) realistic, %d (%.2f%%) unrealistic)\n', nnz(labelsMaj(indAll) == 1), nnz(labelsMaj(indAll) == 1)/nnz(indAll)*100, nnz(labelsMaj(indAll) == 2), nnz(labelsMaj(indAll) == 2)/nnz(indAll)*100);

% Indices of images that are labeled identically by at least 2 labelers
indTwo = (labels(:,1) == labels(:,2) | labels(:,2) == labels(:,3) | labels(:,1) == labels(:,3));
indTwo = indTwo & indGood;
fprintf('%d (%.2f%%) of good images are labeled identically by at least 2 labelers\n', nnz(indTwo), nnz(indTwo)/nnz(indGood)*100);
fprintf('\t(%d (%.2f%%) realistic, %d (%.2f%%) unrealistic)\n', nnz(labelsMaj(indTwo) == 1), nnz(labelsMaj(indTwo) == 1)/nnz(indTwo)*100, nnz(labelsMaj(indTwo) == 2), nnz(labelsMaj(indTwo) == 2)/nnz(indTwo)*100);

fprintf('\n');
%% Their agreement with me

indAllJeff = labels(indJeff & indAll, 1) == labelsJeff(indJeff & indAll);
fprintf('I attributed the same label to %d (%.2f%%) of the images labeled identically by 3 labelers\n', nnz(indAllJeff), nnz(indAllJeff)/nnz(indJeff&indAll)*100);
fprintf('\t(%d realistic, %d unrealistic)\n', nnz(labelsMaj(indAllJeff,1) == 1), nnz(labelsMaj(indAllJeff,1) == 2));

indTwoJeff = labels(indJeff & indTwo, 1) == labelsJeff(indJeff & indTwo);
fprintf('I attributed the same label to %d (%.2f%%) of the images labeled identically by at least 2 labelers\n', nnz(indTwoJeff), nnz(indTwoJeff)/nnz(indJeff&indTwo)*100);
fprintf('\t(%d realistic, %d unrealistic)\n', nnz(labelsMaj(indTwoJeff,1) == 1), nnz(labelsMaj(indTwoJeff,1) == 2));

fprintf('\n');


%% Save the user-provided labelings
outputFilename = fullfile(compiledResultsPath, 'userLabelings.mat');
imageLabel = labelsMaj;
imageLabel(~indTwo) = 0;
imageLabel(1809:3807) = 1;
isGenerated = ones(3807, 1);
isGenerated(1:1808) = 0;
save(outputFilename, 'imageLabel', 'isGenerated');



return;

%% Get examples that I've labeled unrealistic, but these guys didn't.
indJeffU = zeros(length(indJeff), 1);
indJeffU(indJeff) = (labelsJeff(indJeff) == 2);

indLabelersRAll = zeros(length(labelsMaj), 1);
indLabelersRAll(indAll) = (labelsMaj(indAll) == 1);

indLabelersRTwo = zeros(length(labelsMaj), 1);
indLabelersRTwo(indTwo) = (labelsMaj(indTwo) == 1);

indContradAll = indJeffU & indLabelersRAll;
indContradTwo = indJeffU & indLabelersRTwo;

fprintf('%d images were labeled as unrealistic by me, but realistic by all 3 labelers.\n', nnz(indContradAll));
fprintf('%d images were labeled as unrealistic by me, but realistic by at least 2 labelers.\n', nnz(indContradTwo));

%% Let's look at those images

randInd = randperm(nnz(indContradTwo));
tmpInd = find(indContradTwo);
% N = nnz(indContradAll);
N = min(100, nnz(indContradTwo));

indToLoop = tmpInd(randInd(1:N))';

imgDb = labelings{1};
montageImg = zeros(256, 256, 3, N);
for i=indToLoop
    imgPath = fullfile(imageBasePath, imgDb(i).document.image.folder, imgDb(i).document.image.filename);
%     fprintf('Loading %s...\n', imgPath);
    montageImg(:,:,:,indToLoop==i) = im2double(imresize(imread(imgPath), [256 256]));
end

montage(montageImg);


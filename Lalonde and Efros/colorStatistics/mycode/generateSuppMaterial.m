% function generateSuppMaterial

%% Setup paths and load databases
setPath;

outputHtmlPath = fullfile('colorStatistics','suppMaterialWebsite');
compiledResultsPath = fullfile(basePath, 'matchingEvaluation', 'compiledResults');
databasesPath = fullfile(basePath, 'databases');
imagesPath = fullfile(basePath, 'dataset', 'filteredDb', 'Images');
dbPath = fullfile(basePath, 'dataset', 'filteredDb', 'Annotation');

load(fullfile(compiledResultsPath, 'compiledResults.mat')); 
load(fullfile(compiledResultsPath, 'userLabelings.mat'));
load(fullfile(databasesPath, 'userIndicesTrainTest.mat'));
load(fullfile(databasesPath, 'syntheticDb.mat'));

%% Get best local score

c = find(strcmp(colorSpaces, 'lab')); %#ok
t = find(strcmp(techniques, 'objBgDst')); %#ok
dt = find(strcmp(distances, 'distChi')); %#ok
ei = find(strcmp(evalName, 'localEval')); %#ok

scoresLocal = mysqueeze(scores2ndOrder(ei, c, :, t, dt)); %#ok

%% Get best global scores
c = find(strcmp(colorSpaces, 'lab')); %#ok
t = find(strcmp(techniques, 'jointObjColorTexton_threshold_75')); %#ok
dt = find(strcmp(distances, 'distChi')); %#ok
ei = find(strcmp(evalName, 'globalEval')); %#ok

scoresGlobal = mysqueeze(scores2ndOrder(ei, c, :, t, dt)); %#ok

%% Get best combination of global and local scores
thresholdGlobal = 0.35;
[scoresCombination, indGlobal] = combineLocalAndGlobalScores(scoresLocal, scoresGlobal, thresholdGlobal);

%% Loop over the all images in database, sort them according to score
ind = [indUnrealistic; indRealistic; indReal];
gtLabel = [ones(length(indUnrealistic), 1); 2.*ones(length(indRealistic), 1); 3.*ones(length(indReal), 1)];

syntheticDbSmall = syntheticDb(ind);
scoresSmall = scoresCombination(ind);
scoresSmall = ones(size(scoresSmall)) - scoresSmall;
indGlobal = indGlobal(ind);

[sortedScores, sortedInd] = sort(scoresSmall);

htmlInfo = [];
[htmlInfo.experimentNb, htmlInfo.outputDirExperiment, htmlInfo.outputDirFig, ...
    htmlInfo.outputDirJpg, htmlInfo.outputHtmlFileName] = setupBatchTest(outputHtmlPath, '');

%% Loop
cellArray(1,:) = {'Realism score', 'Label', 'Original composite image', 'Recolored Image'};

for i=sortedInd(:)'
    imgInfo = syntheticDbSmall(i).document;
    
    if ~isfield(imgInfo, 'recoloredImage')
        continue;
    end

    if indGlobal(i)
        recoloredImgPath = fullfile(dbPath, imgInfo.image.folder, imgInfo.recoloredImage.glob);
    else
        recoloredImgPath = fullfile(dbPath, imgInfo.image.folder, imgInfo.recoloredImage.loc);
    end
    origImgPath = fullfile(imagesPath, imgInfo.image.folder, imgInfo.image.filename);
    
    fprintf('Copying %s...\n', origImgPath);
    
    % prepare the output file names
    [path, name] = fileparts(imgInfo.file.filename);
    
    outFn = sprintf('%s.jpg', name);
    outFnRecolored = sprintf('%s_recolored.jpg', name);
    
    copyfile(origImgPath, fullfile(htmlInfo.outputDirJpg, outFn));
    copyfile(recoloredImgPath, fullfile(htmlInfo.outputDirJpg, outFnRecolored));
    
    label = {'Unrealistic', 'Realistic', 'Real'};

    % build html structure title row
    cellArray(find(sortedInd==i)+1, :) = {...
        num2str(scoresSmall(i)), ...
        label{gtLabel(i)}, ...
        img2html(fullfile(htmlInfo.outputDirJpg, outFn), fullfile('jpg', outFn), 'Width', 200), ...
        img2html(fullfile(htmlInfo.outputDirJpg, outFnRecolored), fullfile('jpg', outFnRecolored), 'Width', 200) ...
        };
end

% append to html
cell2html(cellArray, htmlInfo.outputHtmlFileName, ...
    'StandAlone', false, 'StyleClass', 'results', 'StyleSheet', '../../../style.css');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function displayMatchingResults
%   Scripts that displays the matching results, pre-computed by doCompileMatchingResults
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function displayMatchingResults(matchingEvaluationDb, syntheticDb)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 
setPath;

basePath = '/nfs/hn01/jlalonde/results/colorStatistics/';
outputBasePath = '/nfs/hn01/jlalonde/status/colorStatistics/';
compiledResultsPath = fullfile(basePath, 'matchingEvaluation', 'compiledResults');
databasesPath = fullfile(basePath, 'databases');

outputPath = fullfile(outputBasePath, 'evalMatchingICCV07');
htmlBasePath = outputPath;

%% Load databases
if nargin ~= 2
    fprintf('Loading databases...'); tic;
    load(fullfile(databasesPath, 'matchingEvaluationDb.mat'));
    load(fullfile(databasesPath, 'syntheticDb.mat'));
    fprintf('done in %fs.\n', toc);
end

% check if the databases are consistent
meFiles = arrayfun(@(x) x.document.image.filename, matchingEvaluationDb, 'UniformOutput', 0);
fFiles = arrayfun(@(x) x.document.image.filename, syntheticDb, 'UniformOutput', 0);

if ~isequal(meFiles, fFiles)
    error('Correspondence problem in the databases!');
end

%% Load precomputed results
load(fullfile(compiledResultsPath, 'compiledResults.mat')); 
load(fullfile(compiledResultsPath, 'labelings.mat'));
load(fullfile(databasesPath, 'indicesTrainTest.mat'));

doSaveHtml = 0;
doSave = 0;

cSpaces = [];
cSpaces = [cSpaces; {'lab', 1}];
% cSpaces = [cSpaces {{'rgb'},2}];
% cSpaces = [cSpaces; {'hsv',3}];
% cSpaces = [cSpaces; {'lalphabeta',4}];

% different distances
dist = [];
dist = [dist {'distChi'}];
dist = [dist {'distEMD'}];
dist = [dist {'distEMDWeighted'}];
% dist = [dist {'distDot'}];

%% Select the techniques
tech = [];

% local techniques
tech = [tech {'objBgDst'}];
tech = [tech {'objBgDstTextonW'}];
% tech = [tech {'objBgDstTextonColorW'}];
% tech = [tech {'objBgSrc'}];
% tech = [tech {'objBgDstW'}];
% tech = [tech {'objBgDstWS'}];
% tech = [tech {'objBgSrcW'}];

% global techniques
% tech = [tech {'jointObj_75'}];
% tech = [tech {'jointObj_50'}];
% tech = [tech {'jointObj_25'}];
% tech = [tech {'margObj_25'}];
% tech = [tech {'margObj_50'}];
% tech = [tech {'margObj_75'}];
% tech = [tech {'jointObj_threshold'}];
% tech = [tech {'jointBg_threshold'}];
% tech = [tech {'margObj_threshold'}];
% tech = [tech {'margBg_threshold'}];
% 
% tech = [tech {'jointObjColorTexton_threshold_0'}];
% tech = [tech {'jointObjColorTexton_threshold_25'}];
% tech = [tech {'jointObjColorTexton_threshold_50'}];
tech = [tech {'jointObjColorTexton_threshold_75'}];
% tech = [tech {'jointObjColorTexton_threshold_100'}];
% 
% tech = [tech {'jointBgColorTexton_threshold_0'}];
% tech = [tech {'jointBgColorTexton_threshold_25'}];
% tech = [tech {'jointBgColorTexton_threshold_50'}];
% tech = [tech {'jointBgColorTexton_threshold_75'}];
% tech = [tech {'jointBgColorTexton_threshold_100'}];

tech = [tech {'jointBgColorTextonSingle_threshold_0'}];
tech = [tech {'jointBgColorTextonSingle_threshold_25'}];
tech = [tech {'jointBgColorTextonSingle_threshold_50'}];
tech = [tech {'jointBgColorTextonSingle_threshold_75'}];
tech = [tech {'jointBgColorTextonSingle_threshold_100'}];

tech = [tech {'jointObjColorTextonSingle_threshold_0'}];
tech = [tech {'jointObjColorTextonSingle_threshold_25'}];
tech = [tech {'jointObjColorTextonSingle_threshold_50'}];
tech = [tech {'jointObjColorTextonSingle_threshold_75'}];
tech = [tech {'jointObjColorTextonSingle_threshold_100'}];

ev = [];
% ev = [ev {'localEval'}];
ev = [ev {'globalEval'}];

% orders = [1 2];
orders = 2;

%% Display the first-order results

% loop over the scores
for s=orders
    for e=1:length(ev)
        for i=1:size(cSpaces,1) %#ok
            for k=1:length(tech) %#ok
                for d=1:length(dist) %#ok
                    c = find(strcmp(colorSpaces, cSpaces{i})); %#ok
                    t = find(strcmp(techniques, tech{k})); %#ok
                    dt = find(strcmp(distances, dist{d})); %#ok
                    ei = find(strcmp(evalName, ev{e})); %#ok 

                    if s==1
                        scores = mysqueeze(scores1stOrder(ei, c, :, t, dt)); %#ok
                        abbrev = '1st';
                    elseif s==2
                        scores = mysqueeze(scores2ndOrder(ei, c, :, t, dt)); %#ok
                        abbrev = '2nd';
                    end

                    if isequal(scores, -ones(size(scores)))
                        % skip this combination: no results are available
                        continue;
                    end

                    [sortedScores, ind] = sort(scores);
                    ind = ind(sortedScores >= 0);
                    
                    displaySeparation(intersect(indRealistic(1:round(length(indRealistic)/2)), ind), intersect(indReal(1:round(length(indReal)/2)), ind), intersect(indUnrealistic, ind), ones(size(scores)) - scores, ...
                        sprintf('%s-order, %s, %s, %s', abbrev, cSpaces{i,1}, tech{k}, dist{d}),...
                        doSave, outputPath, sprintf('Separation_%sorder_%s_%s_%s.jpg', abbrev, cSpaces{i,1}, tech{k}, dist{d}));

                    if doSaveHtml
                        indToSave = [intersect(indRealistic(1:round(length(indRealistic)/2)), ind); intersect(indReal(1:round(length(indReal)/2)), ind); intersect(indUnrealistic, ind)];
                        saveScoresToHtml(syntheticDb(indToSave), scores(indToSave), htmlBasePath, cSpaces{i,1}, tech{k}, dist{d}, abbrev);
                    end

                    if doSave
                        close all;
                    end
                end
            end
        end
    end
end

%% Save stuff to html
function saveScoresToHtml(database, sortedScores, htmlBasePath, colorSpace, technique, distance, order)

% make row vector
sortedScores = sortedScores(:)';

fprintf('Saving to html...');
htmlFile = fullfile(htmlBasePath, sprintf('%s_%s_%s_%s.html', technique, colorSpace, distance, order));

% Get the file list
imgList = arrayfun(@(x)sprintf('<img src="../iccv07_links/filteredDbImages/%s">', x.document.image.filename), database, 'UniformOutput', false)';

% merge the scores and the fileList into one array
% convert to "realism score"
s = mat2cell((ones(size(sortedScores)) - sortedScores)', repmat(1, 1, length(sortedScores)), 1);

% add the labels
labels = arrayfun(@(x)getClassFromLabeling(x.document), database, 'UniformOutput', false)';

% keep only the successfully labeled images
files = arrayfun(@(x) strrep(x.document.file.filename, '.xml', ''), database, 'UniformOutput', false)';
labeledImg = find(arrayfun(@(x)strcmp(x, 'Realistic') || strcmp(x, 'Unrealistic'), labels, 'UniformOutput', true)');
realImgInd = find(arrayfun(@(x)strcmp(x, 'Real'), labels, 'UniformOutput', true)');

% randInd = randperm(length(realImgInd));
% save('indHtml.mat', 'randInd');
% load('indHtml.mat', 'randInd');
% randInd = randInd(1:ceil(length(labeledImg)./2));
% realImgInd = realImgInd(randInd);

imgInd = [labeledImg realImgInd];

imgList = imgList(imgInd);
labels = labels(imgInd);
s = s(imgInd);
files = files(imgInd);

[s1, indS] = sort(cell2mat(s));
imgList = imgList(indS);
labels = labels(indS);
s = s(indS);
files = files(indS);

tableTmp = [files imgList s labels]';

nbColumns = 2;
% add empty lines to fill in all the columns
nbRowsToAdd = nbColumns - mod(size(tableTmp,2),nbColumns);

for i=1:nbRowsToAdd
    tableTmp = [tableTmp {'';'';'';''}];
end

% reshape the table to have 4 image columns
tableTmp = reshape(tableTmp, 4*nbColumns, size(tableTmp,2)/nbColumns)';

table = cell(1,4*nbColumns);
for i=1:nbColumns
    table{1,(i-1)*4+1} = 'Filename';
    table{1,(i-1)*4+2} = 'Image';
    table{1,(i-1)*4+3} = 'Realism Score';
    table{1,(i-1)*4+4} = 'Label';
end

table = [table; tableTmp];

% Need a title for the html
titleStr = sprintf('Matching results, using the %s technique, %s as distance measure, in %s color space', ...
    technique, distance, colorSpace);

% save the results to the html file
writeHtmlHeader(htmlFile, 'style.css', 'Matching evaluation results');
% writeHtmlText(htmlFile, titleStr);
cell2html(table, htmlFile, 'StandAlone', 'false', 'StyleClass', 'results');
fprintf('done.\n');

return;

%% Useful function
function displayImages(doSave, nbImages, indImg, sortedInd, D, testData, imagesPath, titleStr, outputPath, filename, doDrawOutline)

imgs = zeros(256, 256, 3, nbImages, 'uint8');

for j=indImg
    imgPath = fullfile(imagesPath, D(sortedInd(j)).document.image.folder, D(sortedInd(j)).document.image.filename);
    img = imread(imgPath);
    
    ind = find(indImg == j);

    if isfield(testData(sortedInd(j)).document, 'class')
        tags(ceil(ind/sqrt(nbImages)), mod(ind-1,sqrt(nbImages))+1) = testData(sortedInd(j)).document.class(1).type;
    elseif ~sscanf(testData(sortedInd(j)).document.image.generated, '%d')
        tags(ceil(ind/sqrt(nbImages)), mod(ind-1,sqrt(nbImages))+1) = 'r';
    else
        tags(ceil(ind/sqrt(nbImages)), mod(ind-1,sqrt(nbImages))+1) = 'o';
    end

%     if strfind(imgPath, 'generated')
%         tags(ceil(ind/sqrt(nbImages)), mod(ind-1,sqrt(nbImages))+1) = 'G';
%     else
%         tags(ceil(ind/sqrt(nbImages)), mod(ind-1,sqrt(nbImages))+1) = 'O';
%     end

    imgs(:,:,:,ind) = img;
end
warning off Images:initSize:adjustingMag;
figure; montage(imgs); %set(gca, 'Position', get(gca, 'OuterPosition'));

% Display additional information on the images
for j=indImg
    ind = find(indImg == j);
    m = ceil(ind/sqrt(nbImages));
    n = mod(ind-1,sqrt(nbImages))+1;
    
    % draw the object's outline onto the image
    xPoly = str2double(char({testData(sortedInd(j)).document.object.polygon.pt.x})) ./ str2double(testData(sortedInd(j)).document.image.size.width) .* 256;
    yPoly = str2double(char({testData(sortedInd(j)).document.object.polygon.pt.y})) ./ str2double(testData(sortedInd(j)).document.image.size.height) .* 256;
    
    xPoly = [xPoly; xPoly(1)];
    yPoly = [yPoly; yPoly(1)];
    
    wSrc = str2double(testData(sortedInd(j)).document.object.imgSrc.size.width);
    hSrc = str2double(testData(sortedInd(j)).document.object.imgSrc.size.height);

    xPoly = xPoly .* 256 / wSrc;
    yPoly = yPoly .* 256 / hSrc;
    
    xPoly = xPoly + (n-1) * 256;
    yPoly = yPoly + (m-1) * 256;
    
    if doDrawOutline
        line(xPoly, yPoly, 'LineWidth', 1);
    end

    % display the text tags on the top-right corner of each images
    offset = 20;
    pxY = offset + (m-1)*256;
    pxX = (256-offset) + (n-1)*256;
    text(pxX, pxY, tags(m,n));
end
title(strrep(titleStr, '_', '\_'));

if doSave
    fprintf('Saving %s...', filename);
    saveas(gcf, fullfile(outputPath, filename));
    fprintf('done!\n');
end

%%
function displaySeparation(indRealistic, indReal, indUnrealistic, scores, titleStr, doSave, outputPath, filename)

% get the ROC curve from the scores
% [area, tp, fp] = getROCScoreFromScores(scores, indRealistic, indReal, indUnrealistic);
% [area, tp, fp] = getROCScoreFromScores(scores, [], indReal, indUnrealistic);
[area, tp, fp] = getROCScoreFromScores(scores, indRealistic, indReal, indUnrealistic);

figure;
plot(fp, tp, 'LineWidth', 3), xlabel('false positive rate'), ylabel('true positive rate');
if doSave
    title(sprintf('ROC curve with area %f: %s', area, strrep(titleStr, '_', '\_')), 'FontSize', 18);
else
    title(sprintf('ROC curve with area %f: %s', area, strrep(titleStr, '_', '\_'))); 
end

if doSave
    fprintf('Saving %s...', filename);
    saveNiceFigure(gcf, fullfile(outputPath, filename));
    fprintf('done!\n');
end



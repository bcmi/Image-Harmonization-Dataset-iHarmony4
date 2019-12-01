%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doSplitDatasetImages
%  Keep only the good images after a first filtering pass done with qiv
% 
% Input parameters:
%        
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doSplitDatasetImages

addpath ../;
setPath;

basePath = '/nfs/hn01/jlalonde/results/colorStatistics/dataset';

inputBasePath = fullfile(basePath, 'combinedDb');
inputBasePathPopup = fullfile(basePath, 'combinedDbPopup');

outputBasePath = fullfile(basePath, 'filteredDb');
outputBasePathPopup = fullfile(basePath, 'filteredDbPopup');

% goodFilesList = fullfile(basePath, 'filtering', 'goodImages');

% Copy the good files in their new location
% names = textread(goodFilesList, '%s\n');

% Input directories
inputAnnPath = fullfile(inputBasePath, 'Annotation'); 
inputImagesPath = fullfile(inputBasePath, 'Images'); 
inputMasksPath = fullfile(inputAnnPath, 'masks'); 

names = getFilesFromSubdirectories(inputImagesPath, 'image_1', 'jpg');
randInd = randperm(length(names));
names = names(randInd(1:2000));

inputSegmentsPath = fullfile(inputBasePathPopup, 'segments'); 
inputPopupPath = fullfile(inputBasePathPopup, 'popup'); 
inputPopupMaskPath = fullfile(inputBasePathPopup, 'masks');
inputIllContextPath = fullfile(inputBasePathPopup, 'illContext'); 
inputIllContextLabPath = fullfile(inputIllContextPath, 'lab'); 
% inputIllContextHsvPath = fullfile(inputIllContextPath, 'hsv'); 
% inputIllContextRgbPath = fullfile(inputIllContextPath, 'rgb'); 
inputIllContextLalphabetaPath = fullfile(inputIllContextPath, 'lalphabeta'); 

% Create the output directories
outputAnnPath = fullfile(outputBasePath, 'Annotation'); [m,m,m] = mkdir(outputAnnPath); %#ok
outputImagesPath = fullfile(outputBasePath, 'Images'); [m,m,m] = mkdir(outputImagesPath); %#ok
outputMasksPath = fullfile(outputAnnPath, 'masks'); [m,m,m] = mkdir(outputMasksPath); %#ok

outputSegmentsPath = fullfile(outputBasePathPopup, 'segments'); [m,m,m] = mkdir(outputSegmentsPath); %#ok
outputPopupPath = fullfile(outputBasePathPopup, 'popup'); [m,m,m] = mkdir(outputPopupPath); %#ok
outputPopupMaskPath = fullfile(outputBasePathPopup, 'masks'); [m,m,m] = mkdir(outputPopupMaskPath); %#ok
outputIllContextPath = fullfile(outputBasePathPopup, 'illContext'); 
outputIllContextLabPath = fullfile(outputIllContextPath, 'lab'); [m,m,m] = mkdir(outputIllContextLabPath); %#ok
outputIllContextHsvPath = fullfile(outputIllContextPath, 'hsv'); [m,m,m] = mkdir(outputIllContextHsvPath); %#ok
outputIllContextRgbPath = fullfile(outputIllContextPath, 'rgb'); [m,m,m] = mkdir(outputIllContextRgbPath); %#ok
outputIllContextLalphabetaPath = fullfile(outputIllContextPath, 'lalphabeta'); [m,m,m] = mkdir(outputIllContextLalphabetaPath); %#ok

types = {'sky', 'ground', 'vertical'};
histos = {'joint', 'marg_1', 'marg_2', 'marg_3'};
for i=1:length(names)
    name = names{i};
    [p,baseName] = fileparts(name);
    matName = sprintf('%s.mat', baseName);
    xmlName = sprintf('%s.xml', baseName);
    
    fprintf('Copying %s...\n', name);
    
    % Copy the files to their destinations
    safecopy(fullfile(inputAnnPath, xmlName), fullfile(outputAnnPath, xmlName));
    safecopy(fullfile(inputImagesPath, name), fullfile(outputImagesPath, name));
    safecopy(fullfile(inputMasksPath, matName), fullfile(outputMasksPath, matName));
    
    safecopy(fullfile(inputBasePathPopup, xmlName), fullfile(outputBasePathPopup, xmlName));
    safecopy(fullfile(inputSegmentsPath, sprintf('%s_sp.mat', baseName)), fullfile(outputSegmentsPath, sprintf('%s_sp.mat', baseName)));
    safecopy(fullfile(inputPopupPath, matName), fullfile(outputPopupPath, matName));
    safecopy(fullfile(inputPopupPath, sprintf('%s.l.jpg', baseName)), fullfile(outputPopupPath, sprintf('%sl.jpg', baseName)));
    
    for t=1:length(types)
        safecopy(fullfile(inputPopupMaskPath, sprintf('%s_%s.mat', baseName, types{t})), fullfile(outputPopupMaskPath, sprintf('%s_%s.mat', baseName, types{t})));
        
        for h=1:length(histos)
            safecopy(fullfile(inputIllContextLabPath, sprintf('%s_%s_%s.mat', baseName, types{t}, histos{h})), ...
                fullfile(outputIllContextLabPath, sprintf('%s_%s_%s.mat', baseName, types{t}, histos{h})));

%             safecopy(fullfile(inputIllContextHsvPath, sprintf('%s_%s_%s.mat', baseName, types{t}, histos{h})), ...
%                 fullfile(outputIllContextHsvPath, sprintf('%s_%s_%s.mat', baseName, types{t}, histos{h})));

%             safecopy(fullfile(inputIllContextRgbPath, sprintf('%s_%s_%s.mat', baseName, types{t}, histos{h})), ...
%                 fullfile(outputIllContextRgbPath, sprintf('%s_%s_%s.mat', baseName, types{t}, histos{h})));

            safecopy(fullfile(inputIllContextLalphabetaPath, sprintf('%s_%s_%s.mat', baseName, types{t}, histos{h})), ...
                fullfile(outputIllContextLalphabetaPath, sprintf('%s_%s_%s.mat', baseName, types{t}, histos{h})));
        end
    end
end

function safecopy(srcFile, dstFile)

if exist(srcFile, 'file')
    copyfile(srcFile, dstFile);
else 
    fid=fopen('tmp.txt', 'a');
    fprintf(fid, '%s does not exist!\n', srcFile);
    fclose(fid);
end


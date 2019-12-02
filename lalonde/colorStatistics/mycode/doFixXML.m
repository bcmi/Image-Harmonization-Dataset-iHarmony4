function doFixXML% useful function to fix problems in all XMLs in a repository
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath ../xml;
addpath ../database;
addpath ../../3rd_party/LabelMeToolbox;

% define the paths
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/matchingResults/testDataJoint/';
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/matchingResults/testDataJoint/';
subDirs = {'.'};

% dbFn = @dbFnFixHistoSize;
% dbFn = @dbFnFixClass;
% dbFn = @dbFnFixPolygon;
% dbFn = @dbFnFixOriginal;
% dbFn = @dbFnFixPpm;
dbFn = @dbFnFixTextons;

% call the database
processResultsDatabaseFast(dbPath, outputBasePath, subDirs, dbFn);


function dbFnFixTextons(imgInfo, dbPath, outputBasePath, varargin)

[pathstr, fileName, ext, versn] = fileparts(imgInfo.image.filename);
xmlPath = fullfile(outputBasePath, sprintf('%s.xml', fileName));

if isfield(imgInfo.colorStatistics(1).matchingEvaluationHistoBgNN, 'chi')
    imgInfo.colorStatistics(1).matchingEvaluationHistoBgNNTextons.chi = imgInfo.colorStatistics(1).matchingEvaluationHistoBgNN.chi;
    imgInfo.colorStatistics(1).matchingEvaluationHistoBgNNTextons.dot = imgInfo.colorStatistics(1).matchingEvaluationHistoBgNN.dot;

    imgInfo.colorStatistics(1).matchingEvaluationHistoBgNN = rmfield(imgInfo.colorStatistics(1).matchingEvaluationHistoBgNN, 'chi');
    imgInfo.colorStatistics(1).matchingEvaluationHistoBgNN = rmfield(imgInfo.colorStatistics(1).matchingEvaluationHistoBgNN, 'dot');

%     a=1;
    writeStructToXML(imgInfo, xmlPath);
end



function dbFnFixPpm(imgInfo, dbPath, outputBasePath, varargin)

imgInfo.image.filename = strrep(imgInfo.image.filename, '.ppm', '.jpg');
imgInfo.image.folder = 'images';

[pathstr, fileName, ext, versn] = fileparts(imgInfo.image.filename);
xmlPath = fullfile(outputBasePath, sprintf('%s.xml', fileName));

writeStructToXML(imgInfo, xmlPath);



function dbFnFixPolygon(imgInfo, dbPath, outputBasePath, varargin)

% load tmp2.mat;
labelmeImagesPath = '/nfs/hn21/projects/labelme/Images/';
[pathstr, fileName, ext, versn] = fileparts(imgInfo.image.filename);

xmlPath = fullfile(outputBasePath, sprintf('%s.xml', fileName));
if strfind(fileName, 'generated')

    if isfield(imgInfo.object, 'imgSrc')
        % recover the original image
        origFn = imgInfo.object.imgSrc;
        origImg = imread(origFn);
        [h,w,c] = size(origImg);
        
        imgInfo.object = rmfield(imgInfo.object, 'imgSrc');
        
        imgInfo.object.imgSrc.path = origFn;
        imgInfo.object.imgSrc.size.width = w;
        imgInfo.object.imgSrc.size.height = h;

        writeStructToXML(imgInfo, xmlPath);
    else
        fprintf('Ouch! imgSrc in %s was lost!!\n', fileName);
    end
else
    imgInfo.object.imgSrc.path = fullfile(labelmeImagesPath, imgInfo.image.originalFolder, imgInfo.image.originalFilename);
    imgInfo.object.imgSrc.size.width = imgInfo.image.origSize.width;
    imgInfo.object.imgSrc.size.height = imgInfo.image.origSize.height;
    
    writeStructToXML(imgInfo, xmlPath);
end


function dbFnFixLabeler(imgInfo, dbPath, outputBasePath, varargin)

[pathstr, fileName, ext, versn] = fileparts(imgInfo.image.filename);
xmlPath = fullfile(outputBasePath, imgInfo.image.folder, sprintf('%s.xml', fileName));

if isfield(imgInfo, 'class')
    imgInfo.class.labelerId = 1;
%     type = imgInfo.class;
%     imgInfo = rmfield(imgInfo, 'class');
%     imgInfo.class.type = type;
    
    fprintf('Saving xml file: %s\n', xmlPath);
    writeStructToXML(imgInfo, xmlPath);
end

function dbFnFixOriginal(imgInfo, dbPath, outputBasePath, varargin)

xmlPath = fullfile(outputBasePath, imgInfo.image.folder, imgInfo.image.filename);
xmlPath = strrep(xmlPath, '.jpg', '.xml');

if isempty(strfind(imgInfo.image.filename, 'generated'))
    if isfield(imgInfo, 'class')
        nbLabelers = length(imgInfo.class);
        
        for i=1:nbLabelers
            imgInfo.class(i).type = 'r';
        end
        fprintf('Saving xml file: %s\n', xmlPath);
        writeStructToXML(imgInfo, xmlPath);
    end
end




function dbFnFixClass(imgInfo, dbPath, outputBasePath, varargin)

xmlPath = fullfile(outputBasePath, imgInfo.image.folder, imgInfo.image.filename);
xmlPath = strrep(xmlPath, '.jpg', '.xml');

if isfield(imgInfo, 'class')
    type = imgInfo.class;
    imgInfo = rmfield(imgInfo, 'class');
    imgInfo.class.type = type;
    
    fprintf('Saving xml file: %s\n', xmlPath);
    writeStructToXML(imgInfo, xmlPath);
end





function dbFnFixHistoSize(imgInfo, dbPath, outputBasePath, varargin)

xmlPath = fullfile(outputBasePath, imgInfo.image.folder, imgInfo.image.filename);
xmlPath = strrep(xmlPath, '.jpg', '.xml');

for i=1:3
    imgInfo.colorStatistics(i).secondOrder.marginal.nbBins = 128;
    imgInfo.colorStatistics(i).secondOrder.pairwise.nbBins = 32;
end

fprintf('Saving xml file: %s\n', xmlPath);
writeStructToXML(imgInfo, xmlPath);



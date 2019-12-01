% useful function to fix problems in all XMLs in a repository
function doFixXML
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath ../;
setPath;

% define the paths
% imagesBasePath = '/usr1/projects/labelme/Images/';
% annotationsBasePath = '/usr1/projects/labelme/Annotation/';
% outputBasePath = '/nfs/hn01/jlalonde/results/msStitching/labelmeDb/';
% dbPath = '/nfs/hn24/home/jlalonde/results/colorStatistics/dataset/syntheticDb/Annotation';
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/objectDb/';
% dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/dataset/filteredDb/Annotation';
% dbFn = @dbFnAddFilename;
% dbFn = @dbFnAddOrigImg;
% dbFn = @dbFnAddSignatures;
dbFn = @dbFnAddLab;

% Call the database function
parallelized = 0;
randomized = 0;
processResultsDatabaseFast(dbPath, '', dbPath, dbFn, parallelized, randomized);

function r=dbFnAddLab(outputBasePath, annotation, varargin)
r=0;

if exist(fullfile(outputBasePath, annotation.file.folder, 'histograms', 'lab', strrep(annotation.file.filename, '.xml', '.mat')), 'file')
    annotation.histograms(1).filename = fullfile('histograms', 'lab', strrep(annotation.file.filename, '.xml', '.mat'));
    annotation.histograms(1).nbBins = 50;
    annotation.histograms(1).colorSpace = 'lab';

    xmlPath = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);
    writeXML(xmlPath, annotation);
end


function r=dbFnAddSignatures(outputBasePath, annotation, varargin)
r=0;

annotation.signatures(1).colorSpace = 'lab';
annotation.signatures(1).nbClusters = 100;
annotation.signatures(1).filename = fullfile('signatures', 'lab', ...
                                             strrep(annotation.file.filename, '.xml', '.mat'));

annotation.signatures(2).colorSpace = 'rgb';
annotation.signatures(2).nbClusters = 100;
annotation.signatures(2).filename = fullfile('signatures', 'rgb', ...
                                             strrep(annotation ...
                                                  .file.filename, ...
                                                  '.xml', '.mat'));

annotation.signatures(3).colorSpace = 'hsv';
annotation.signatures(3).nbClusters = 100;
annotation.signatures(3).filename = fullfile('signatures', 'hsv', ...
                                             strrep(annotation ...
                                                  .file.filename, ...
                                                  '.xml', '.mat'));

annotation.signatures(4).colorSpace = 'lalphabeta';
annotation.signatures(4).nbClusters = 100;
annotation.signatures(4).filename = fullfile('signatures', 'lalphabeta', ...
                                             strrep(annotation ...
                                                  .file.filename, ...
                                                  '.xml', '.mat'));

xmlPath = fullfile(outputBasePath, annotation.file.folder, ...
                   annotation.file.filename);
writeXML(xmlPath, annotation);

function r=dbFnAddOrigImg(outputBasePath, annotation, varargin)
r=0;

annotation.objImgSrc = annotation.imageSrc;
annotation.bgImgSrc = annotation.imageSrc;

annotation = rmfield(annotation, 'imageSrc');

xmlPath = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);
writeXML(xmlPath, annotation);


function r=dbFnAddFilename(outputBasePath, annotation, varargin)
r=0;

annotation.file.filename = annotation.filename;
annotation.file.folder = annotation.folder;

annotation = rmfield(annotation, 'filename');
annotation = rmfield(annotation, 'folder');

% annotation.filename = strrep(annotation.image.filename, '.jpg', '.xml');
% annotation.folder = annotation.image.folder;

xmlPath = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);
writeXML(xmlPath, annotation);
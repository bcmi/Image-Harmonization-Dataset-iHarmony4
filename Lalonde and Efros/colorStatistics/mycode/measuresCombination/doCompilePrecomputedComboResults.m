%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doCompilePrecomputedComboResults
%   
% 
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doCompilePrecomputedComboResults
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath ../;
setPath;

% define the input and output paths
basePath = '/nfs/hn01/jlalonde/results/colorStatistics';
dbBasePath = fullfile(basePath, 'dataset', 'filteredDb');
dbPath = fullfile(dbBasePath, 'Annotation');
outputBasePath = fullfile(basePath, 'measuresCombination');

dbFn = @dbFnCompilePrecomputedComboResults;

% thresholds to try
sigmasHistos = 0:0.05:1;
sigmasSignatures = 5:5:100;

global accHistDistChi accHistOverlapW accSignaturesMeanPixelShifts accSignaturesMeanClusterShifts ...
    accSignaturesPctDistW accSignaturesPctDist accSignaturesBestSigma;

% pre-allocate the global variables
files = getFilesFromSubdirectories(dbPath, '', 'xml');
accHistDistChi = zeros(3, length(files), length(sigmasHistos));
accHistOverlapW = zeros(3, length(files), length(sigmasHistos));

accSignaturesMeanPixelShifts = zeros(2, length(files), length(sigmasSignatures));
accSignaturesMeanClusterShifts = zeros(2, length(files), length(sigmasSignatures));
accSignaturesPctDistW = zeros(2, length(files), length(sigmasSignatures));
accSignaturesPctDist = zeros(2, length(files), length(sigmasSignatures));
accSignaturesBestSigma = zeros(2, length(files));

% call the database function
parallelized = 0;
randomized = 0;
processResultsDatabaseFast(dbPath, '', dbPath, dbFn, parallelized, randomized, 'DbPath', dbPath);

% save the results to file
save(fullfile(outputBasePath, 'concatData.mat'), 'accHistDistChi', 'accHistOverlapW', ...
    'accSignaturesMeanPixelShifts', 'accSignaturesMeanClusterShifts', 'accSignaturesPctDistW', ...
    'accSignaturesPctDist', 'accSignaturesBestSigma');

%%
function r=dbFnCompilePrecomputedComboResults(outputBasePath, annotation, varargin) 
global accHistDistChi accHistOverlapW processDatabaseImgNumber accSignaturesMeanPixelShifts ...
    accSignaturesMeanClusterShifts accSignaturesPctDistW accSignaturesPctDist accSignaturesBestSigma;
r=0;

% read arguments
defaultArgs = struct('DbPath', []);
args = parseargs(defaultArgs, varargin{:});

% load the histogram combined results
for i=1:length(annotation.evalCombo.histograms)
    % overlapW, distChi
    load(fullfile(args.DbPath, annotation.evalCombo.histograms(i).filename)); 
    
    accHistDistChi(i, processDatabaseImgNumber, :) = distChi;
    accHistOverlapW(i, processDatabaseImgNumber, :) = overlapW;
end

% load the signatures combined results
for i=1:length(annotation.evalCombo.signaturesEMD)
    % sigmas, meanPixelShifts, meanClusterShifts, pctDistW, pctDist, bestSigma
    load(fullfile(args.DbPath, annotation.evalCombo.signaturesEMD(i).filename)); 
    
    accSignaturesMeanPixelShifts(i, processDatabaseImgNumber, :) = meanPixelShifts;
    accSignaturesMeanClusterShifts(i, processDatabaseImgNumber, :) = meanClusterShifts;
    accSignaturesPctDistW(i, processDatabaseImgNumber, :) = pctDistW;
    accSignaturesPctDist(i, processDatabaseImgNumber, :) = pctDist;
    accSignaturesBestSigma(i, processDatabaseImgNumber) = bestSigma;
end


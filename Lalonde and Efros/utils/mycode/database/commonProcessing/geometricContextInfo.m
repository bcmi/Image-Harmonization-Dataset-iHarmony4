%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [classifiers, segmentExec] = geometricContextInfo
%  Loads default parameters for the geometric context algorithm
% 
% Input parameters:
%
%        
% Output parameters:
%  - classifiers: classifiers data structure
%  - segmentExec: path to superpixel segmenter executable
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [classifiers, segmentExec] = geometricContextInfo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load the classifiers
codePath = '/nfs/hn01/jlalonde/code/';
baseClassifierData = fullfile(codePath, 'matlab', 'trunk', '3rd_party', 'geometricContext', 'classifiers');
classifiers = load(fullfile(baseClassifierData, 'ijcvClassifier.mat'));

% executable path for the superpixel segmenter
segmentExec = fullfile(codePath, 'c++', 'trunk', '3rd_party', 'segment', 'segment');

[s,r] = system('hostname -s');
if ~isempty(strfind(r, 'balaton')) || ~isempty(strfind(r, 'pbv-server'))
    segmentExec = [segmentExec '_64'];
end
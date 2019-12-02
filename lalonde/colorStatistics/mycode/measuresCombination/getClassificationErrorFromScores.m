%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [rocScore, tp, fp] = getROCScoreFromScores(scores, indRealistic, indReal, indUnrealistic)
%   
% 
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errors = getClassificationErrorFromScores(thresholds, scores, indValid, indRealistic, indReal, indUnrealistic)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% make row vector
scores = scores(:)';

indConcat = [indRealistic; indReal; indUnrealistic];

% keep only the validInd that correspond to the correct labels
indValid = indValid(indConcat);

classifScores = scores(indConcat);
gtLabels = zeros(length(classifScores), length(thresholds));
gtLabels(1:(length(indRealistic)+length(indReal)), :)= 1;

% 1=realistic, 0=unrealistic
classifLabels = repmat(classifScores(:), 1, length(thresholds)) < repmat(thresholds(:)', length(classifScores), 1);
% force the valid indices to be realistic (1)
classifLabels(indValid,:) = 1; 

% count the number of differences (normalized)
errors = sum(double(xor(classifLabels, gtLabels)), 1) ./ length(classifScores);

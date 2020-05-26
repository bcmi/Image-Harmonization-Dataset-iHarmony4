%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [rocScore, tp, fp] = getROCScoreFromScores(scores, indRealistic, indReal, indUnrealistic)
%   
% 
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rocScore, tp, fp] = getROCScoreFromScores(scores, indRealistic, indReal, indUnrealistic)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% make row vector
scores = scores(:)';
y = [scores(indRealistic) scores(indReal) scores(indUnrealistic)];
x = zeros(1, length(y));
x(1:(length(indRealistic)+length(indReal)))= 1;

[tp, fp] = roc(x',y');
rocScore = max(auroc(tp, fp), 1-auroc(tp, fp));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function scores = combineLocalAndGlobalScores(scoresLocal, scoresGlobal, globalThreshold)
%   Get new scores based on the combination of local and global scores. Assume they are all in the
%   [0,1] interval
% 
% Input parameters:
%
% Output parameters:
%   - scores: realism scores obtained from combining local and global scores
%   - indGlobal: indices of images where the global score was used
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [scores, indGlobal] = combineLocalAndGlobalScores(scoresLocal, scoresGlobal, globalThreshold)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

scores = zeros(size(scoresLocal));
indGlobal = scoresGlobal <= globalThreshold;
scores(indGlobal) = 0;
scores(scoresGlobal > globalThreshold) = scoresLocal(scoresGlobal > globalThreshold);
scores(scoresLocal < 0) = scoresGlobal(scoresLocal < 0);
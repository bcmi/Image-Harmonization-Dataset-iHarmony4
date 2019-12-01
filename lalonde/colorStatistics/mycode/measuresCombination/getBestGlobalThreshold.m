%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [bestThreshold, bestScore] = getBestGlobalThreshold(scoresGlobal, scoresLocal, indRealistic, indReal, indUnrealistic)
%   Retrieve the best threshold and score from combining a global and local method
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [bestThreshold, bestScore] = getBestGlobalThreshold(scoresGlobal, scoresLocal, indRealistic, indReal, indUnrealistic)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tInc = 0:0.025:1;

scores = zeros(1, length(scoresGlobal));
rocScores = zeros(length(tInc), 1);

for t=tInc
    scores = combineLocalAndGlobalScores(scoresLocal, scoresGlobal, t);
    rocScores(tInc==t) = getROCScoreFromScores(scores, indRealistic, indReal, indUnrealistic);
end

indMax = argmax(rocScores);
bestThreshold = tInc(indMax);
bestScore = rocScores(indMax);

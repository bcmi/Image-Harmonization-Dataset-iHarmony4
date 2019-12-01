%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnCompileMatching(imgInfo, outputBasePath, varargin)
%   Accumulates matching results over several imagaes
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dbFnCompileMatching(imgInfo, outputBasePath, varargin)global cumulative1stOrderChi cumulative2ndOrderChi colorSpaces;
% load tmp.mat
addpath ../../3rd_party/parseArgs;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check if the user specified the option to recompute
defaultArgs = struct('Recompute', 0);
args = parseargs(defaultArgs, varargin{:});

% look if the information was computed
if isfield(imgInfo, 'colorStatistics')

    % loop over all the computed color spaces
    for c=1:size(imgInfo.colorStatistics, 2)
        if isfield(imgInfo.colorStatistics(c), 'matchingEvaluation')

            % read the 1st order
            dist1stOrderChi = sscanf(imgInfo.colorStatistics(c).matchingEvaluation.firstOrder.distChi, '%f');
            dist1stOrderDot = sscanf(imgInfo.colorStatistics(c).matchingEvaluation.firstOrder.distDot, '%f');
            
            if size(cumulative1stOrderChi, 2) < c
                cumulative1stOrderChi{c} = dist1stOrderChi;
            else
                cumulative1stOrderChi{c} = [cumulative1stOrderChi{c} dist1stOrderChi];
            end

            % read the 2nd order
            filePath = fullfile(outputBasePath, imgInfo.image.folder, imgInfo.colorStatistics(c).matchingEvaluation.secondOrder.histFile);

            % load the .mat file
            histDistChi = []; histDistDot = [];
            load(filePath);
            
            if size(cumulative2ndOrderChi, 2) < c
                cumulative2ndOrderChi{c} = histDistChi;
            else
                cumulative2ndOrderChi{c} = cumulative2ndOrderChi{c} + histDistChi;
            end

            % store the color space
            if size(colorSpaces, 2) < c
                colorSpaces{c} = imgInfo.colorStatistics(c).colorSpace;
            end
        end
    end
end


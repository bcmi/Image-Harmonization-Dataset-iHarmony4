%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function plotEMD(figureHandle, centers1, centers2, flowEMD)
%  Plot the emd by tracing lines between each matched centers, with thickness and intensity 
%  proportional to the weight of each connection (from the flow)  
% 
% Input parameters:
%   - figureHandle: handle of figure where to draw the signature
%   - centers1: cluster centers of distribution 1 (typically obtained by k-means clustering)
%   - centers2: cluster centers of distribution 2 (typically obtained by k-means clustering)
%   - flowEMD: flow computed by the EMD from dist 1 to dist 2. (direct output from emd_mex)
%
% Output parameters:
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotEMD(figureHandle, centers1, centers2, flowEMD)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cMap = colormap(gray(256));

% overlay lines with thickness proportional to weight
figure(figureHandle), hold on;
for i=1:size(flowEMD,1)
    line([centers1(flowEMD(i,1), 1) centers2(flowEMD(i,2), 1)], ...
        [centers1(flowEMD(i,1), 2) centers2(flowEMD(i,2), 2)], ...
        [centers1(flowEMD(i,1), 3) centers2(flowEMD(i,2), 3)], ...
        'Color', cMap(257-floor(flowEMD(i,3) / max(flowEMD(:,3)) * 255 + 1), :), ...
        'LineWidth', flowEMD(i,3) / max(flowEMD(:,3)) * 5);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function visualize2ndOrderStatistics
%   
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function visualize2ndOrderStatistics 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load the histogram (6 dimensions)
histoPath = '/nfs/hn01/jlalonde/results/colorStatistics/naturalSceneCategories/cumulHistogram/total2nd.mat';
load(histoPath);

% consider only the L*a*b* color space
for j=1:length(colorSpaces)
    if strcmp(colorSpaces{j}, 'lab')
        labInd = j;
    end
end

secondOrderHisto = total2ndOrder{labInd};
nbBins = size(secondOrderHisto, 1);

%% Generate histograms for each color
h = figure;
for i=1:nbBins
%     i = 13;
%     t = zeros(nbBins, nbBins, 1, nbBins^2);
    % Clear the figure
    clf(h);
    a = zeros(nbBins^2, 1);
    for j=1:nbBins
        for k=1:nbBins
            % Get the 3-D histo corresponding to that color
            histo = squeeze(secondOrderHisto(i,j,k,:,:,:));

            % Generate a A-B plot
            histoAB = squeeze(sum(histo, 1));

            if ~isempty(find(histo))
                % Normalize, and put between 0 and 255
                histoAB = histoAB ./ sum(histoAB(:));
                histoAB = floor(histoAB .* 255);
                % t(:,:,1,(j-1)*nbBins+k) = histoAB;
                
               
%                 subplot(nbBins, nbBins*2, (j-1)*(nbBins*2)+2*k, 'align');
%                 imshow(zeros(nbBins, nbBins, 3));
            end
            
            subplot(nbBins, nbBins, (j-1)*(nbBins)+k, 'align');
            a((j-1)*nbBins+k) = image(histoAB); axis off;

        end
    end 
    
    for m=1:length(a);
        p = get(a(m), 'Parent');
        outerPos = get(p, 'OuterPosition');
        set(p, 'Position', outerPosition);
        
%         line([outerPosition(0) outerPosition(0)+outerPosition(3)], [outerPosition(1) outerPosition(1)]);
    end
    
    drawnow;
    saveas(gcf, sprintf('histo_L=%02d.tif', i));
end


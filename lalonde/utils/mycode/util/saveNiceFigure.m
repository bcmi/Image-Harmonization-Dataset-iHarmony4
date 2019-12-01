%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function saveNiceFigure(figureHandle, filename)
% 
% Input parameters:
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveNiceFigure(figureHandle, filename, outputSize)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

axisHandle = get(figureHandle, 'CurrentAxes');
fontSize = get(axisHandle, 'FontSize');

set(axisHandle, 'FontSize', 18);

% allow for multiple use at the same time
tmpFilename = sprintf('tmp_%d.jpg', round(rand*1e6));

% save to tmp file
saveas(figureHandle, tmpFilename);

% re-load, subsample and save to final location
img = imread(tmpFilename);
 
% fucking stupid trick to remove the margins
imgTmp = max(img, [], 3);
[r,c] = find(imgTmp < 255);
img = img(min(r):max(r), min(c):max(c), :);
if nargin > 2
    img = imresize(img, outputSize, 'bilinear');
else
%     img = imresize(img, 0.5, 'bilinear');
end
imwrite(img, filename);

delete(tmpFilename);

% revert back to original settings
set(axisHandle, 'FontSize', fontSize);

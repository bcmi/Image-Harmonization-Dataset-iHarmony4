%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function saveJpgFigure(figHandle, outputFilename, resolution, quality, tight, size)
%  Save figure to jpg, with good quality and resolution
% 
% Input parameters:
%   - figHandle: Handle to the figure to save
%   - outputFilename: Name of the file to save
%
% Output parameters:
%   None. 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveJpgFigure(figHandle, outputFilename, resolution, quality, tight, size)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2008 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    resolution = 300;
end

if nargin < 4
    quality = 100;
end

if nargin < 5
    tight = 0;
end

if nargin < 6
    size = [];
end

if tight == 1
    set(gca(figHandle), 'OuterPosition', [0 0 1 1], 'Position', [0 0 1 1]);
elseif tight == 2
%     set(gca(figHandle), 'ActivePositionProperty', 'Position');
    tightInset = get(gca(figHandle), 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1];
    set(gca(figHandle), 'Position', get(gca(figHandle), 'OuterPosition') - tightInset);
%     set(gca(figHandle), 'OuterPosition', [0 0 1 1], 'Position', ([0 0 1 1]-tightInset));
end

if ~isempty(size)
    set(figHandle, 'Position', [0 0 size(1) size(2)]);
end

% figure(figHandle);
% set(gca(figHandle), 'Position', get(gca(figHandle), 'OuterPosition'));
set(figHandle, 'PaperPositionMode', 'auto');
set(figHandle, 'InvertHardcopy','off');
print(sprintf('-djpeg%d', quality), sprintf('-r%d', resolution), sprintf('-f%d', figHandle), outputFilename);






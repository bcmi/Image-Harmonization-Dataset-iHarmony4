function combinedDist = computeGlobalDistanceMeasure(...
    colorConcatHistPath, textonConcatHistPath, ...
    colorHist, textonHist, type, alpha)
% Computes the global distance measure between a piece of an image (object
% or background) and a large database of images
%
%   [score, indNearestNeighbor] = computeGlobalDistanceMeasure(...
%       colorConcatHistPath, textonConcatHistPath, colorHist, textonHist, ...
%       type, alpha)
%
%   - type can be either 'Obj' or 'Bg'
%   - alpha must be between 0 and 1 and represents the blend between color
%   and texture information.

assert(strcmp(type, 'Obj') || strcmp(type, 'Bg'), ...
    'type must be either ''Obj'' or ''Bg''');
assert(alpha >= 0 && alpha <= 1, 'Alpha must be between 0 and 1');

colorHistFiles = dir(fullfile(colorConcatHistPath, sprintf('*lab_joint%s*', type)));
colorHistFiles = {colorHistFiles(:).name};

textonHistFiles = dir(fullfile(textonConcatHistPath, sprintf('*texton%s*', type)));
textonHistFiles = {textonHistFiles(:).name};

% Note: this should take forever.
alpha = 0.75;

% compute color histogram distance
if alpha > 0
    colorDist = computeDistance(colorConcatHistPath, colorHistFiles, ...
        colorHist, 'color');
else 
    colorDist = 0;
end

% compute texton histogram distance
if alpha < 1
    textonDist = computeDistance(textonConcatHistPath, textonHistFiles, ...
        textonHist, 'texton');
else
    textonDist = 0;
end

combinedDist = alpha*colorDist + (1-alpha)*textonDist;


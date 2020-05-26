%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnCompileLabeling
%   Scripts that compiles the labelings.
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r=dbFnCompileLabeling(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize
r=0;
global isGenerated imageLabel processDatabaseImgNumber;

% read arguments
% defaultArgs = struct();
% args = parseargs(defaultArgs, varargin{:});

n = processDatabaseImgNumber;

isGenerated(n) = str2double(annotation.image.generated);

if ~isGenerated(n)
    % realistic
    imageLabel(n) = 1;
elseif isfield(annotation, 'class')
    c = getClassFromLabeling(annotation);
    switch c
        case 'Realistic' % realistic
            imageLabel(n) = 1;
        case 'Unrealistic' % realistic
            imageLabel(n) = 2;
        otherwise % (unlabeled, other, unsuccessful)
            imageLabel(n) = 3;
    end
end

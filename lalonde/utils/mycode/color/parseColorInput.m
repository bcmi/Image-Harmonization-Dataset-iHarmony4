function [C1, C2, C3, type] = parseColorInput(varargin)
% Helper to parse the inputs to the color conversion functions.
%
%
% See also:
%   parseColorOutput
%
% ----------
% Jean-Francois Lalonde

if nargin == 1
    if ndims(varargin{1}) == 3
        % we're given an image
        C1 = varargin{1}(:,:,1);
        C2 = varargin{1}(:,:,2);
        C3 = varargin{1}(:,:,3);
        
        type = 1;
    elseif ismatrix(varargin{1})
        % we're given a 3xN array
        assert(size(varargin{1}, 1) == 3, ...
            'Input must be of size 3xN');
        
        C1 = varargin{1}(1,:);
        C2 = varargin{1}(2,:);
        C3 = varargin{1}(3,:);
        
        type = 2;
        
    else
        error('Input must have either 2 or 3 dimensions');
    end
    
elseif nargin == 3
    % we're given the 3 channels independently
    C1 = varargin{1};
    C2 = varargin{2};
    C3 = varargin{3};
    
    type = 3;
    
else
    error('Need either one or 3 inputs');
end

assert(isfloat(C1) && isfloat(C2) && isfloat(C3), ...
    'Input must be in floating-point format');
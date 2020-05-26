function out = parseColorOutput(C1, C2, C3, type, varargin)
% Helper function to parse the output of color conversion functions
% 
% See also:
%   parseColorInput
% 
% ----------
% Jean-Francois Lalonde


switch type
    case 1
        % image
        [nrows, ncols, ~] = size(varargin{1});
        C1 = reshape(C1, [nrows, ncols]);
        C2 = reshape(C2, [nrows, ncols]);
        C3 = reshape(C3, [nrows, ncols]);
        out{1} = cat(3, C1, C2, C3);
        
    case 2
        % 3xN vector
        out{1} = cat(1, row(C1), row(C2), row(C3));
        
    case 3
        % independent channels
        out{1} = reshape(C1, size(varargin{1}));
        out{2} = reshape(C2, size(varargin{2}));
        out{3} = reshape(C3, size(varargin{3}));
end
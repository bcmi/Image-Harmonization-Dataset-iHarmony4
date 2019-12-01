function varargout = rgb2srgb(varargin)
% Converts RGB to sRGB data.
%
%   img = rgb2srgb(img)
%   vec = rgb2srgb(vec)
%   [r,g,b] = rgb2srgb(r, g, b)
%
% Takes in image, vector (3xN) or independent channels.
%
% See http://en.wikipedia.org/wiki/SRGB
%
% ----------
% Jean-Francois Lalonde

[R, G, B, type] = parseColorInput(varargin{:});

% apply the colorspace transformation
R = srgbTrans(R);
G = srgbTrans(G);
B = srgbTrans(B);

    function C = srgbTrans(C)
        t = 0.0031308;
        a = 0.055;

        C(C<=t) = 12.92.*C(C<=t);
        C(C>t)  = (1+a).*C(C>t).^(1/2.4)-a;
    end

varargout = parseColorOutput(R, G, B, type, varargin{:});

end
function varargout = srgb2rgb(varargin)
% Converts sRGB to RGB data.
%
%   img = srgb2rgb(img)
%   vec = srgb2rgb(vec)
%   [r,g,b] = srgb2rgb(r, g, b)
%
% Takes in image, vector (3xN) or independent channels.
%
% See http://en.wikipedia.org/wiki/SRGB
%
% ----------
% Jean-Francois Lalonde

[R, G, B, type] = parseColorInput(varargin{:});

% apply the colorspace transformation
R = srgbInvTrans(R);
G = srgbInvTrans(G);
B = srgbInvTrans(B);

    function C = srgbInvTrans(C)
        t = 0.04045;
        a = 0.055;

        C(C<=t) = C(C<=t)./12.92;
        C(C>t)  = ((C(C>t)+a)./(1+a)).^(2.4);
    end

varargout = parseColorOutput(R, G, B, type, varargin{:});

end
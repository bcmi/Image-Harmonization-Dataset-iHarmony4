% DERIVATIVE5 - 7-Tap 1st and 2nd discrete derivatives
%
% This function computes 1st and 2nd derivatives of an image using the 7-tap
% coefficients given by Farid and Simoncelli.  The results are significantly
% more accurate than MATLAB's GRADIENT function on edges that are at angles
% other than vertical or horizontal. This in turn improves gradient orientation
% estimation enormously.
%
% Usage:  [gx, gy, gxx, gyy, gxy] = derivative7(im, derivative specifiers)
%
% Arguments:
%                       im - Image to compute derivatives from.
%    derivative specifiers - A comma separated list of character strings
%                            that can be any of 'x', 'y', 'xx', 'yy' or 'xy'
%                            These can be in any order, the order of the
%                            computed output arguments will match the order
%                            of the derivative specifier strings.
% Returns:
%  Function returns requested derivatives which can be:
%     gx, gy   - 1st derivative in x and y
%     gxx, gyy - 2nd derivative in x and y
%     gxy      - 1st derivative in y of 1st derivative in x
%
%  Examples:
%    Just compute 1st derivatives in x and y
%    [gx, gy] = derivative7(im, 'x', 'y');  
%                                           
%    Compute 2nd derivative in x, 1st derivative in y and 2nd derivative in y
%    [gxx, gy, gyy] = derivative7(im, 'xx', 'y', 'yy')
%
% See also: DERIVATIVE5

% Reference: Hany Farid and Eero Simoncelli "Differentiation of Discrete
% Multi-Dimensional Signals" IEEE Trans. Image Processing. 13(4): 496-508 (2004)

% Copyright (c) 2010 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% http://www.csse.uwa.edu.au/~pk/research/matlabfns/
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.
%
% April 2010

function varargout = derivative7(im, varargin)

    varargin = varargin(:);
    varargout = cell(size(varargin));

    % 7-tap interpolant and 1st and 2nd derivative coefficients
    p  = [ 0.004711  0.069321  0.245410  0.361117  0.245410  0.069321  0.004711];
    d1 = [ 0.018708  0.125376  0.193091  0.000000 -0.193091 -0.125376 -0.018708];
    d2 = [ 0.055336  0.137778 -0.056554 -0.273118 -0.056554  0.137778  0.055336];
    
    % Compute derivatives.  Note that in the 1st call below MATLAB's conv2
    % function performs a 1D convolution down the columns using p then a 1D
    % convolution along the rows using d1. etc etc.
    gx = false;    
    for n = 1:length(varargin)
      if strcmpi('x', varargin{n})
          varargout{n} = conv2(p, d1, im, 'same');    
          gx = true;   % Record that gx is available for gxy if needed
          gxn = n;
      elseif strcmpi('y', varargin{n})
          varargout{n} = conv2(d1, p, im, 'same');
      elseif strcmpi('xx', varargin{n})
          varargout{n} = conv2(p, d2, im, 'same');    
      elseif strcmpi('yy', varargin{n})
          varargout{n} = conv2(d2, p, im, 'same');
      elseif strcmpi('xy', varargin{n}) | strcmpi('yx', varargin{n})
          if gx
              varargout{n} = conv2(d1, p, varargout{gxn}, 'same');
          else
              gx = conv2(p, d1, im, 'same');    
              varargout{n} = conv2(d1, p, gx, 'same');
          end
      else
          error(sprintf('''%s'' is an unrecognized derivative option',varargin{n}));
      end
    end
    

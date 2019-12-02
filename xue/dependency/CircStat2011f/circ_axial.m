function alpha = circ_axial(alpha, p)
%
% alpha = circ_axial(alpha, p)
%   Transforms p-axial data to a common scale.
%
%   Input:
%     alpha	sample of angles in radians
%     [p		number of modes]
%
%   Output:
%     alpha transformed data
%
% PHB 2009
%
% References:
%   Statistical analysis of circular data, N. I. Fisher
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens/circStat.html



if nargin < 2
    p = 1;
end

alpha = mod(alpha*p,2*pi);

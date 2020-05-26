% CIRCLEINTERSECT - Finds intersection of two circles.
%
% Function to return the intersection points between two circles
% given their centres and radi.
%
% Usage: [i1, i2] = circleintersect(c1, r1, c2, r2, lr)
%
% Where:
%         c1 and c2 are 2-vectors specifying the centres of the two circles.
%         r1 and r2 are the radii of the two circles.
%         i1 and i2 are the two 2D intersection points (if they exist)
%         lr is an optional string specifying what solution is wanted:
%            'l' for the solution to the left of the line from c1 to c2
%            'r' for the solution to the right of the line from c1 to c2
%            'lr' if both solutions are wanted (default).

%  Peter Kovesi  
%  School of Computer Science & Software Engineering
%  The University of Western Australia
%  Peter Kovesi
%  pk @ csse uwa edu au
%  http://www.csse.uwa.edu.au/~pk
%
%  April   2000   - original version
%  October 2003   - mods to allow selection of left/right solutions
%                   and catching of degenerate triangles

function [i1, i2] = circleintersect(c1, r1, c2, r2, lr)

if nargin == 4
  lr = 'lr';
end

maxmag = max([max(r1, r2), max(c1), max(c2)]);  % maximum value in data input
tol = 100*(maxmag+1)*eps;  % Tolerance used for deciding whether values are equal
                           % scaling by 100 is a bit arbitrary...

bv = (c2-c1);         % Baseline vector from c1 to c2
b = norm(bv);         % The distance between the centres

% Trap case of  baseline of zero length.  If r1 == r2
% we have a valid geometric situation, but there are an infinite number of
% solutions.  Here we simply choose to add r1 in the x direction to c1.
if b < eps & abs(r1-r2) < tol  
  i1 = c1 + [r1 0];
  i2 = i1;
  return
end

bv = bv/b;            % Normalise baseline vector.
bvp = [-bv(2) bv(1)]; % Vector perpendicular to baseline

% Trap the degenerate cases where one of the radii are zero, or nearly zero

if r1 < tol & abs(b-r2) < tol
  i1 = c1;
  i2 = c1;
  return;
elseif r2 < tol & abs(b-r1) < tol
  i1 = c2;
  i2 = c2;
  return;
end

% Check triangle inequality
if b > (r1+r2) | r1 > (b+r2) | r2 > (b+r1)
  c1,  c2, r1, r2, b
  error('No solution to circle intersection');
end

% Normal solution
cosR2 = (b^2 + r1^2 - r2^2)/(2*b*r1);
sinR2 = sqrt(1-cosR2^2);

if strcmpi(lr,'lr')                    
  i1 = c1 + r1*cosR2*bv + r1*sinR2*bvp;   % 'left' solution
  i2 = c1 + r1*cosR2*bv - r1*sinR2*bvp;   % and 'right solution
elseif strcmpi(lr,'l')
  i1 = c1 + r1*cosR2*bv + r1*sinR2*bvp;   % 'left' solution
  i2 = [];
elseif strcmpi(lr,'r')
  i1 = c1 + r1*cosR2*bv - r1*sinR2*bvp;   % 'right solution
  i2 = [];
else
  error('illegal left/right solution request');
end

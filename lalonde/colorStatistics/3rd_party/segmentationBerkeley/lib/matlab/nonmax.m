function [im] = nonmax(im,theta)
% function [im] = nonmax(im,theta)
%
% Perform non-max suppression on im orthogonal to theta.  Theta can be
% a matrix providing a different theta for each pixel or a scalar
% proving the same theta for every pixel.
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% March 2003

if numel(theta)==1,
  theta = theta .* ones(size(im));
end

% Do non-max suppression orthogonal to theta.
theta = mod(theta+pi/2,pi);

% The following diagram depicts the 8 cases for non-max suppression.
% Theta is valued in [0,pi), measured clockwise from the positive x
% axis.  The 'o' marks the pixel of interest, and the eight
% neighboring pixels are marked with '.'.  The orientation is divided
% into 8 45-degree blocks.  Within each block, we interpolate the
% image value between the two neighboring pixels.
%
%        .66.77.                                
%        5\ | /8                                
%        5 \|/ 8                                
%        .--o--.-----> x-axis                     
%        4 /|\ 1                                
%        4/ | \1                                
%        .33.22.                                
%           |                                   
%           |
%           v
%         y-axis                                  
%
% In the code below, d is always the distance from A, so the distance
% to B is (1-d).  A and B are the two neighboring pixels of interest
% in each of the 8 cases.  Note that the clockwise ordering of A and B
% changes from case to case in order to make it easier to compute d.

% Determine which pixels belong to which cases.
mask15 = ( theta>=0 & theta<pi/4 );
mask26 = ( theta>=pi/4 & theta<pi/2 );
mask37 = ( theta>=pi/2 & theta<pi*3/4 );
mask48 = ( theta>=pi*3/4 & theta<pi );

mask = ones(size(im));
[h,w] = size(im);
[ix,iy] = meshgrid(1:w,1:h);

% case 1
idx = find( mask15 & ix<w & iy<h);
idxA = idx + h;
idxB = idx + h + 1;
d = tan(theta(idx));
imI = im(idxA).*(1-d) + im(idxB).*d;
mask(idx(find(im(idx)<imI))) = 0;

% case 5
idx = find( mask15 & ix>1 & iy>1);
idxA = idx - h;
idxB = idx - h - 1;
d = tan(theta(idx));
imI = im(idxA).*(1-d) + im(idxB).*d;
mask(idx(find(im(idx)<imI))) = 0;

% case 2
idx = find( mask26 & ix<w & iy<h );
idxA = idx + 1;
idxB = idx + h + 1;
d = tan(pi/2-theta(idx));
imI = im(idxA).*(1-d) + im(idxB).*d;
mask(idx(find(im(idx)<imI))) = 0;

% case 6
idx = find( mask26 & ix>1 & iy>1 );
idxA = idx - 1;
idxB = idx - h - 1;
d = tan(pi/2-theta(idx));
imI = im(idxA).*(1-d) + im(idxB).*d;
mask(idx(find(im(idx)<imI))) = 0;

% case 3
idx = find( mask37 & ix>1 & iy<h );
idxA = idx + 1;
idxB = idx - h + 1;
d = tan(theta(idx)-pi/2);
imI = im(idxA).*(1-d) + im(idxB).*d;
mask(idx(find(im(idx)<imI))) = 0;

% case 7
idx = find( mask37 & ix<w & iy>1 );
idxA = idx - 1;
idxB = idx + h - 1;
d = tan(theta(idx)-pi/2);
imI = im(idxA).*(1-d) + im(idxB).*d;
mask(idx(find(im(idx)<imI))) = 0;

% case 4
idx = find( mask48 & ix>1 & iy<h );
idxA = idx - h;
idxB = idx - h + 1;
d = tan(pi-theta(idx));
imI = im(idxA).*(1-d) + im(idxB).*d;
mask(idx(find(im(idx)<imI))) = 0;

% case 8
idx = find( mask48 & ix<w & iy>1 );
idxA = idx + h;
idxB = idx + h - 1;
d = tan(pi-theta(idx));
imI = im(idxA).*(1-d) + im(idxB).*d;
mask(idx(find(im(idx)<imI))) = 0;

% apply mask
im = im .* mask;

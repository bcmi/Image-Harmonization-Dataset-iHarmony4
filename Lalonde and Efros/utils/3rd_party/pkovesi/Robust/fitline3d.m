% FITLINE3D - Fits a line to a set of 3D points
%
% Usage:   [L] = fitline3d(XYZ)
%
% Where: XYZ - 3xNpts array of XYZ coordinates
%               [x1 x2 x3 ... xN;
%                y1 y2 y3 ... yN;
%                z1 z2 z3 ... zN]
%
% Returns: L - 3x2 matrix consisting of the two endpoints of the line
%              that fits the points.  The line is centered about the
%              mean of the points, and extends in the directions of the
%              principal eigenvectors, with scale determined by the
%              eigenvalues.
%
% Author: Felix Duvallet (CMU)
% August 2006



function L = fitline3d(XYZ)

% Since the covariance matrix should be 3x3 (not NxN), need
% to take the transpose of the points.
XYZ = XYZ';

% find mean of the points
mu = mean(XYZ, 1);

% covariance matrix
C = cov(XYZ);

% get the eigenvalues and eigenvectors
[V, D] = eig(C);

% largest eigenvector is in the last column
col = size(V, 2);  %get the number of columns

% get the last eigenvector column and the last eigenvalue
eVec = V(:, col);
eVal = D(col, col);

% start point - center about mean and scale eVector by eValue
L(:, 1) = mu' - sqrt(eVal)*eVec;
% end point
L(:, 2) = mu' + sqrt(eVal)*eVec;


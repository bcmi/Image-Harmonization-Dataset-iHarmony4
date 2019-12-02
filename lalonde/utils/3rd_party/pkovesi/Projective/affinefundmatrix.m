% AFFINEFUNDMATRIX - computes affine fundamental matrix from 4 or more points
%
% Function computes the affine fundamental matrix from 4 or more matching
% points in a stereo pair of images.  The Gold Standard algorithm given
% by Hartley and Zisserman p351 (2nd Ed.) is used. 
%
% Usage:   [F, e1, e2] = affinefundmatrix(x1, x2)
%          [F, e1, e2] = affinefundmatrix(x)
%
% Arguments:
%          x1, x2 - Two sets of corresponding point.  If each set is 3xN
%                   it is assumed that they are homogeneous coordinates.
%                   If they are 2xN it is assumed they are inhomogeneous.
%         
%          x      - If a single argument is supplied it is assumed that it
%                   is in the form x = [x1; x2]
% Returns:
%          F      - The 3x3 fundamental matrix such that x2'*F*x1 = 0.
%          e1     - The epipole in image 1 such that F*e1 = 0
%          e2     - The epipole in image 2 such that F'*e2 = 0
%

% Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/~pk
%
% Feb 2005 


function [F,e1,e2] = affinefundmatrix(varargin)
    
    [x1, x2, npts] = checkargs(varargin(:));

    X = [x2; x1];      % Form vectors of correspondences
    Xmean = mean(X,2); % Mean 

    deltaX = zeros(size(X));
    for k = 1:4
	deltaX(k,:) = X(k,:) - Xmean(k);
    end
        
    [U,D,V] = svd(deltaX',0);
    
    % Form  fundamental matrix from the column of V corresponding to
    % smallest singular value.
    v = V(:,4);
    F = [ 0    0    v(1)
	  0    0    v(2)
	 v(3) v(4) -v'*Xmean];
    
    % Solve for epipoles
    [U,D,V] = svd(F,0);
    e1 = V(:,3);
    e2 = U(:,3);
    
%--------------------------------------------------------------------------
% Function to check argument values and set defaults

function [x1, x2, npts] = checkargs(arg);
    
    if length(arg) == 2
        x1 = arg{1};
        x2 = arg{2};
        if ~all(size(x1)==size(x2))
            error('x1 and x2 must have the same size');
        elseif size(x1,1) == 3
	    % Convert to inhomogeneous coords
            x1(1,:) = x1(1,:)./x1(3,:);
            x1(2,:) = x1(2,:)./x1(3,:);	    
            x2(1,:) = x2(1,:)./x2(3,:);
            x2(2,:) = x2(2,:)./x2(3,:);	    	    
	    x1 = x1(1:2,:);   x2 = x2(1:2,:);
        elseif size(x1,1) ~= 2
	    error('x1 and x2 must be 2xN or 3xN arrays');
        end
        
    elseif length(arg) == 1
        if size(arg{1},1) == 6
            x1 = arg{1}(1:3,:);
            x2 = arg{1}(4:6,:);
	    % Convert to inhomogeneous coords
            x1(1,:) = x1(1,:)./x1(3,:);
            x1(2,:) = x1(2,:)./x1(3,:);	    
            x2(1,:) = x2(1,:)./x2(3,:);
            x2(2,:) = x2(2,:)./x2(3,:);	    	    	    
	    x1 = x1(1:2,:);   x2 = x2(1:2,:);	    
        elseif size(arg{1},1) == 4
            x1 = arg{1}(1:2,:);
            x2 = arg{1}(3:4,:);	    
	else
	    error('Single argument x must be 6xN');
        end
    else
        error('Wrong number of arguments supplied');
    end
      
    npts = size(x1,2);
    if npts < 4
        error('At least 4 points are needed to compute the affine fundamental matrix');
    end
    

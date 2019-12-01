% RIDGEORIENT - Estimates the local orientation of ridges in a fingerprint
%
% Usage:  [orientim, reliability, coherence] = ridgeorientation(im, gradientsigma,...
%                                             blocksigma, ...
%                                             orientsmoothsigma)
%
% Arguments:  im                - A normalised input image.
%             gradientsigma     - Sigma of the derivative of Gaussian
%                                 used to compute image gradients.
%             blocksigma        - Sigma of the Gaussian weighting used to
%                                 sum the gradient moments.
%             orientsmoothsigma - Sigma of the Gaussian used to smooth
%                                 the final orientation vector field. 
%                                 Optional: if ommitted it defaults to 0
% 
% Returns:    orientim          - The orientation image in radians.
%                                 Orientation values are +ve clockwise
%                                 and give the direction *along* the
%                                 ridges.
%             reliability       - Measure of the reliability of the
%                                 orientation measure.  This is a value
%                                 between 0 and 1. I think a value above
%                                 about 0.5 can be considered 'reliable'.
%                                 reliability = 1 - Imin./(Imax+.001);
%             coherence         - A measure of the degree to which the local
%                                 area is oriented.
%                                 coherence = ((Imax-Imin)./(Imax+Imin)).^2;
%
% With a fingerprint image at a 'standard' resolution of 500dpi suggested
% parameter values might be:
%
%    [orientim, reliability] = ridgeorient(im, 1, 3, 3);
%
% See also: RIDGESEGMENT, RIDGEFREQ, RIDGEFILTER

% May 2003      Original version by Raymond Thai,  
% January 2005  Reworked by Peter Kovesi           
% October 2011  Added coherence computation and orientsmoothsigma made optional
%
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/~pk


function [orientim, reliability, coherence] = ...
             ridgeorient(im, gradientsigma, blocksigma, orientsmoothsigma)
        
    if ~exist('orientsmoothsigma', 'var'), orientsmoothsigma = 0; end
    [rows,cols] = size(im);
    
    % Calculate image gradients.
    sze = fix(6*gradientsigma);   if ~mod(sze,2); sze = sze+1; end
    f = fspecial('gaussian', sze, gradientsigma); % Generate Gaussian filter.
    [fx,fy] = gradient(f);                        % Gradient of Gausian.
    
    Gx = filter2(fx, im); % Gradient of the image in x
    Gy = filter2(fy, im); % ... and y
    
    % Estimate the local ridge orientation at each point by finding the
    % principal axis of variation in the image gradients.
   
    Gxx = Gx.^2;       % Covariance data for the image gradients
    Gxy = Gx.*Gy;
    Gyy = Gy.^2;
    
    % Now smooth the covariance data to perform a weighted summation of the
    % data.
    sze = fix(6*blocksigma);   if ~mod(sze,2); sze = sze+1; end    
    f = fspecial('gaussian', sze, blocksigma);
    Gxx = filter2(f, Gxx); 
    Gxy = 2*filter2(f, Gxy);
    Gyy = filter2(f, Gyy);
    
    % Analytic solution of principal direction
    denom = sqrt(Gxy.^2 + (Gxx - Gyy).^2) + eps;
    sin2theta = Gxy./denom;            % Sine and cosine of doubled angles
    cos2theta = (Gxx-Gyy)./denom;

    if orientsmoothsigma
        sze = fix(6*orientsmoothsigma);   if ~mod(sze,2); sze = sze+1; end    
        f = fspecial('gaussian', sze, orientsmoothsigma);    
        cos2theta = filter2(f, cos2theta); % Smoothed sine and cosine of
        sin2theta = filter2(f, sin2theta); % doubled angles
    end
    
    orientim = pi/2 + atan2(sin2theta,cos2theta)/2;

    % Calculate 'reliability' of orientation data.  Here we calculate the
    % area moment of inertia about the orientation axis found (this will
    % be the minimum inertia) and an axis  perpendicular (which will be
    % the maximum inertia).  The reliability measure is given by
    % 1.0-min_inertia/max_inertia.  The reasoning being that if the ratio
    % of the minimum to maximum inertia is close to one we have little
    % orientation information. 
    
    Imin = (Gyy+Gxx)/2 - (Gxx-Gyy).*cos2theta/2 - Gxy.*sin2theta/2;
    Imax = Gyy+Gxx - Imin;
    
    reliability = 1 - Imin./(Imax+.001);
    coherence = ((Imax-Imin)./(Imax+Imin)).^2;
    
    % Finally mask reliability to exclude regions where the denominator
    % in the orientation calculation above was small.  Here I have set
    % the value to 0.001, adjust this if you feel the need
    reliability = reliability.*(denom>.001);
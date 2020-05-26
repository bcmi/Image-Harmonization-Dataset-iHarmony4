% FREQCOMP - Demonstrates image reconstruction from Fourier components
%
% Usage:  recon = freqcomp(im, Npts, delay)
%
% Arguments:      im    - Image to be reconstructed.
%                 Npts  - Number of frequency components to consider
%                         (defaults to 50).
%                 delay - Optional time delay between animations of the
%                         reconstruction. If this is omitted the function
%                         waits for a key to be pressed before moving to
%                         the next component.
%
% Returns:        recon - The image reconstructed from the specified
%                         number of components
%
% This program displays:
%
%    * The image.
%    * The Fourier transform (spectrum) of the image with a conjugate
%      pair of Fourier components marked with red dots.
%    * The sine wave basis function that corresponds to the Fourier
%      transform pair marked in the image above.  
%    * The reconstruction of the image generated from the sum of the sine
%      wave basis functions considered so far.

% Copyright (c) 2002-2003 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% http://www.csse.uwa.edu.au/
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% March 2002 - Original version
% April 2003 - General cleanup of code

function recon = freqcomp(im, Npts, delay)
    
    if ndims(im) == 3
	im = rgb2gray(im);
	warning('converting colour image to greyscale');
    end
    
    if nargin < 2
	Npts = 50;
    end
    
    [rows,cols] = size(im);
    
    % If necessary crop one row and/or column so that there are an even
    % number of rows and columns, this makes things easier later.
    if mod(rows,2) % odd
	rows = rows-1;
    end
    if mod(cols,2) % odd
	cols = cols-1;
    end

    im = im(1:rows,1:cols);
    rc = fix(rows/2)+1;      % Centre point
    cc = fix(cols/2)+1;

    % The following code constructs two arrays of coordinates within the FFT
    % of the image that correspond to complex conjugate pairs of points that
    % spiral out from the centre visiting every frequency component on
    % the way.
    p1 = zeros(Npts,2);    % Path 1
    p2 = zeros(Npts,2);    % Path 2
    
    m = zeros(rows,cols);  % Matrix for marking visited points
    m(rc,cc) = 1;
    m(rc,cc-1) = 1;
    m(rc,cc+1) = 1;    
    
    p1(1,:) = [rc cc-1];
    p2(1,:) = [rc cc+1];    
    d1 = [0 -1];  % initial directions of the paths
    d2 = [0  1];
    
    % Mark out two symmetric spiral paths out from the centre (I wish I
    % could think of a neater way of doing this)
    
    for n = 2:Npts
	l1 = [-d1(2) d1(1)];  % left direction
	l2 = [-d2(2) d2(1)];	
	
	lp1 = p1(n-1,:) + l1; % coords of point in left direction
	lp2 = p2(n-1,:) + l2;	
	
	if ~m(lp1(1), lp1(2)) % go left
	    p1(n,:) = lp1;
	    d1 = l1;
	    m(p1(n,1), p1(n,2)) = 1; % mark point as visited
	else  % go sraight ahead
	    p1(n,:) = p1(n-1,:) + d1;
	    m(p1(n,1), p1(n,2)) = 1; % mark point as visited
	end

	if ~m(lp2(1), lp2(2)) % go left
	    p2(n,:) = lp2;
	    d2 = l2;
	    m(p2(n,1), p2(n,2)) = 1; % mark point as visited
	else  % go sraight ahead
	    p2(n,:) = p2(n-1,:) + d2;
	    m(p2(n,1), p2(n,2)) = 1; % mark point as visited
	end
	
    end
    
    % Having constructed the path of frequency components to be visited
    % we take the FFT of the image and then enter a loop that
    % incrementally reconstructs the image from its components.
    
    IM = fftshift(fft2(im));
    recon = zeros(rows,cols);       % Initialise reconstruction matrix
       
    if max(rows,cols) < 150
	fontsze = 7;
    else
	fontsze = 10;
    end
    
    figure(1), clf
    subplot(2,2,1),imagesc(im),colormap gray, axis image, axis off
    title('Original Image','FontSize',fontsze);
    subplot(2,2,2),imagesc(log(abs(IM))),colormap gray, axis image
    axis off,   title('Fourier Transform + frequency component pair','FontSize',fontsze);
    
    warning off % Turn off warnings that might arise if the images cannot be
                % displayed full size
    truesize(1) 

    for n = 1:Npts
	  
	  % Extract the pair of Fourier components
	  F = zeros(rows,cols);
	  F(p1(n,1), p1(n,2)) = IM(p1(n,1), p1(n,2));
	  F(p2(n,1), p2(n,2)) = IM(p2(n,1), p2(n,2));	  
	  
	  % Invert and add  to reconstruction
	  f = real(ifft2(fftshift(F)));
	  recon = recon+f;
	  
	  % Display results
	  subplot(2,2,2),imagesc(log(abs(IM))),colormap gray, axis image
          axis off,  title('Fourier Transform + frequency component pair','FontSize',fontsze);
	  hold on, plot([p1(n,2), p2(n,2)], [p1(n,1), p2(n,1)],'r.'); hold  off
	  subplot(2,2,3),imagesc(recon),colormap gray, axis image, axis off, title('Reconstruction','FontSize',fontsze);
	  subplot(2,2,4),imagesc(f),colormap gray, axis image, axis off
	  title('Basis function corresponding to frequency component pair','FontSize',fontsze);	  

	  if nargin == 3
	      pause(delay);
	  else
	      fprintf('Hit any key to continue \n'); pause
	  end
	  
    end
    
    warning on  % Restore warnings




% Demonstration of feature matching via simple correlation, and then using
% RANSAC to estimate the fundamental matrix and at the same time identify
% (mostly) inlying matches
%
% Usage:  testfund              - Demonstrates fundamental matrix calculation
%                                 on two default images
%         testfund(im1,im2)     - Computes fundamental matrix on two supplied images
%
% Edit code as necessary to tweak parameters

% Copyright (c) 2004-2005 Peter Kovesi
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

% February 2004
% August   2005 Octave compatibility

function testfund(im1,im2)
    
    if nargin == 0
	im1 = imread('im02.jpg');
	im2 = imread('im03.jpg');
    end

    v = version; Octave=v(1)<'5';  % Crude Octave test        
    thresh = 500;   % Harris corner threshold
    nonmaxrad = 3;  % Non-maximal suppression radius
    dmax = 50;      % Maximum search distance for matching
    w = 11;         % Window size for correlation matching
    
    % Find Harris corners in image1 and image2
    [cim1, r1, c1] = harris(im1, 1, thresh, 3);
    show(im1,1), hold on, plot(c1,r1,'r+');

    [cim2, r2, c2] = harris(im2, 1, thresh, 3);
    show(im2,2), hold on, plot(c2,r2,'r+');
    drawnow

    correlation = 1;  % Change this between 1 or 0 to switch between the two
                      % matching functions below
    
    if correlation  % Use normalised correlation matching
	[m1,m2] = matchbycorrelation(im1, [r1';c1'], im2, [r2';c2'], w, dmax);
	
    else            % Use monogenic phase matching
	nscale = 1;
	minWaveLength = 10;
	mult = 4;
	sigmaOnf = .2;
	[m1,m2] = matchbymonogenicphase(im1, [r1';c1'], im2, [r2';c2'], w, dmax,...
					nscale, minWaveLength, mult, sigmaOnf);
    end    
    
    % Display putative matches
    show(im1,3), set(3,'name','Putative matches')
    if Octave, figure(1); title('Putative matches'), axis('equal'), end        
    for n = 1:length(m1);
	line([m1(2,n) m2(2,n)], [m1(1,n) m2(1,n)])
    end

    % Assemble homogeneous feature coordinates for fitting of the
    % fundamental matrix, note that [x,y] corresponds to [col, row]
    x1 = [m1(2,:); m1(1,:); ones(1,length(m1))];
    x2 = [m2(2,:); m2(1,:); ones(1,length(m1))];    
    
    t = .002;  % Distance threshold for deciding outliers
    
    % Change the commenting on the lines below to switch between the use
    % of 7 or 8 point fundamental matrix solutions, or affine fundamental
    % matrix solution.
%   [F, inliers] = ransacfitfundmatrix7(x1, x2, t, 1);    
    [F, inliers] = ransacfitfundmatrix(x1, x2, t, 1);
%   [F, inliers] = ransacfitaffinefund(x1, x2, t, 1);    

    fprintf('Number of inliers was %d (%d%%) \n', ...
	    length(inliers),round(100*length(inliers)/length(m1)))
    fprintf('Number of putative matches was %d \n', length(m1))        
    
    % Display both images overlayed with inlying matched feature points
    
    if Octave
	figure(4); title('Inlying matches'), axis('equal'), 
    else
        show(im1,4), set(4,'name','Inlying matches'), hold on
    end        
    plot(m1(2,inliers),m1(1,inliers),'r+');
    plot(m2(2,inliers),m2(1,inliers),'g+');    

    for n = inliers
	line([m1(2,n) m2(2,n)], [m1(1,n) m2(1,n)],'color',[0 0 1])
    end

    if Octave, return, end
    
    response = input('Step through each epipolar line [y/n]?\n','s');
    if response == 'n'
	return
    end    
    
    % Step through each matched pair of points and display the
    % corresponding epipolar lines on the two images.
    
    l2 = F*x1;    % Epipolar lines in image2
    l1 = F'*x2;   % Epipolar lines in image1
    
    % Solve for epipoles
    [U,D,V] = svd(F);
    e1 = hnormalise(V(:,3));
    e2 = hnormalise(U(:,3));
 
    for n = inliers
	figure(1), clf, imshow(im1), hold on, plot(x1(1,n),x1(2,n),'r+');
	hline(l1(:,n)); plot(e1(1), e1(2), 'g*');

	figure(2), clf, imshow(im2), hold on, plot(x2(1,n),x2(2,n),'r+');
	hline(l2(:,n)); plot(e2(1), e2(2), 'g*');
	fprintf('hit any key to see next point\r'); pause
    end

    fprintf('                                         \n');
    
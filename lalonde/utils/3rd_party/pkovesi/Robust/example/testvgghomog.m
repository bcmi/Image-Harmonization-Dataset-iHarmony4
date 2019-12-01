% Demonstration of feature matching via simple correlation, and then using
% RANSAC to estimate the homography between two images and at the same time
% identify (mostly) inlying matches
%
% Usage:  testhomog              - Demonstrates homography calculation on two 
%                                  default images
%         testhomog(im1,im2)     - Computes homography on two supplied images
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

function testvgghomog(im1,im2)

    if nargin == 0
	im1 = imread('boats.tif');
	im2 = imread('boatsrot.tif');    
    end
    
    close all    
    v = version; Octave=v(1)<'5';  % Crude Octave test
    thresh = 500;   % Harris corner threshold
    nonmaxrad = 3;  % Non-maximal suppression radius
    dmax = 50;
    w = 11;         % Window size for correlation matching
    
    % Find Harris corners in image1 and image2
    [cim1, r1, c1] = harris(im1, 1, thresh, 3);
    show(im1,1), hold on, plot(c1,r1,'r+');

    [cim2, r2, c2] = harris(im2, 1, thresh, 3);
    show(im2,2), hold on, plot(c2,r2,'r+');

    drawnow

    [m1,m2] = matchbycorrelation(im1, [r1';c1'], im2, [r2';c2'], w, dmax);

    % Display putative matches
    show(im1,3), set(3,'name','Putative matches'), 
    if Octave, figure(1); title('Putative matches'), axis('equal'), end    
    for n = 1:length(m1);
	line([m1(2,n) m2(2,n)], [m1(1,n) m2(1,n)])
    end

    % Assemble homogeneous feature coordinates for fitting of the
    % homography, note that [x,y] corresponds to [col, row]
    x1 = [m1(2,:); m1(1,:); ones(1,length(m1))];
    x2 = [m2(2,:); m2(1,:); ones(1,length(m1))];    
    
    t = .001;  % Distance threshold for deciding outliers
    [H, inliers] = ransacfithomography_vgg(x1, x2, t);

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


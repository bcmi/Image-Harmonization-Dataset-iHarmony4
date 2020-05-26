% Demonstration of feature matching via simple correlation, and then using
% RANSAC to estimate the fundamental matrix and at the same time identify
% (mostly) inlying matches

% Peter Kovesi  
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/~pk
%
% February 2004
% August   2005  Octave version

function testfundOctave

    close all    
    
    thresh = 500;   % Harris corner threshold
    nonmaxrad = 3;  % Non-maximal suppression radius
    dmax = 50;
    w = 11;    % Window size for correlation matching
    
    im1 = imread('im02.jpg');
    im2 = imread('im03.jpg');

    % Find Harris corners in image1 and image2
    [cim1, r1, c1] = harris(im1, 1, thresh, 3);
%    show(im1,1), hold on, plot(c1,r1,'r+');

    [cim2, r2, c2] = harris(im2, 1, thresh, 3);
%    show(im2,2), hold on, plot(c2,r2,'r+');

    drawnow


    [m1,m2] = matchbycorrelation(im1, [r1';c1'], im2, [r2';c2'], w, dmax);

    % Display putative matches
%    show(im1,3), set(3,'name','Putative matches'), hold on    
    for n = 1:length(m1);
	line([m1(2,n) m2(2,n)], [m1(1,n) m2(1,n)])
    end

    % Assemble homogeneous feature coordinates for fitting of the
    % fundamental matrix, note that [x,y] corresponds to [col, row]
    x1 = [m1(2,:); m1(1,:); ones(1,length(m1))];
    x2 = [m2(2,:); m2(1,:); ones(1,length(m1))];    
    
    t = .001;  % Distance threshold for deciding outliers
    [F, inliers] = ransacfitfundmatrix(x1, x2, t);

    fprintf('Number of inliers was %d (%d%%) \n', ...
	    length(inliers),round(100*length(inliers)/length(m1)))
    fprintf('Number of putative matches was %d \n', length(m1))        
    
    % Display both images overlayed with inlying matched feature points
%    show(double(im1)+double(im2),4), set(4,'name','Inlying matches'), hold on 
    plot(m1(2,inliers),m1(1,inliers),'r+');
    plot(m2(2,inliers),m2(1,inliers),'g+');    

    for n = inliers
	line([m1(2,n) m2(2,n)], [m1(1,n) m2(1,n)],'color',[0 0 1])
    end
   

    
    % Step through each matched pair of points and display the
    % corresponding epipolar lines on the two images.
    
    l2 = F*x1;    % Epipolar lines in image2
    l1 = F'*x2;   % Epipolar lines in image1

    
    % Solve for epipoles
    [U,D,V] = svd(F,0);
    e1 = hnormalise(V(:,3));
    e2 = hnormalise(U(:,3));
    
    return
    
    for n = inliers
	figure(1), clf, imshow(im1), hold on, plot(x1(1,n),x1(2,n),'r+');
	hline(l1(:,n)); plot(e1(1), e1(2), 'g*');

	figure(2), clf, imshow(im2), hold on, plot(x2(1,n),x2(2,n),'r+');
	hline(l2(:,n)); plot(e2(1), e2(2), 'g*');
	fprintf('hit any key to see next point\r'); pause
    end

    fprintf('                                         \n');
    
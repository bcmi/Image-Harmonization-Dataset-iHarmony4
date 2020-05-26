% DIGIPTS - digitise points in an image
%
% Function to digitise points in an image.  Points are digitised by clicking
% with the left mouse button.  Clicking any other button terminates the
% function.  Each location digitised is marked with a red '+'.
%
% Usage:  [u,v] = digipts
%
% where u and v are  nx1 arrays of x and y coordinate values digitised in
% the image.
%
% This function uses the cross-hair cursor provided by GINPUT.  This is
% much more useable than IMPIXEL

% Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk @ csse uwa edu au
% http://www.csse.uwa.edu.au/~pk
% 
% May 2002

function [u,v] = digipts
    
    hold on
    u = []; v = [];
    but = 1;
    while but == 1
	[x y but] = ginput(1);
	if but == 1
	    u = [u;x];
	    v = [v;y];
	    
	    plot(u,v,'r+');
	end
    end
    
    hold off

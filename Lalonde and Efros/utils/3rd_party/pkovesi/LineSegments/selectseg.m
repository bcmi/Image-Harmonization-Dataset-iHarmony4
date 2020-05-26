% SELECTSEG - Interactive selection of linesegments with mouse.
%
% Usage: segs = selectseg(seglist);
%                            
%         seglist - an Nx4 array storing line segments in the form
%                    [x1 y1 x2 y2
%                     x1 y1 x2 y2
%                         . .     ] etc 
%
%
% See also:  EDGELINK, LINESEG, MAXLINEDEV, MERGESEG
%

% Copyright (c) 2000-2005 Peter Kovesi
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

% December 2000

function segs = selectseg(seglist);

segs = [];
selectedSegs = [NaN];

figure(1), clf, drawseg(seglist,1);


Nseg = size(seglist,1);

    fprintf('Select segments by clicking with the left mouse button\n');
    fprintf('Last segment is indicated by clicking with any other mouse button\n');

    count = 0;
    but = 1;
    while but==1 & count < Nseg
        [xp,yp,but] = ginput(1);       % Get digitised point
	count = count + 1;	
	rmin = Inf;
	for s = 1:Nseg
	    r = segdist(xp,yp,seglist(s,:));
	    % if distance is closest so far and segment is not already
            % selected...
	    if r < rmin & ~any(selectedSegs==s)
		rmin = r;
		closestseg = seglist(s,:);
                smin = s;
	    end
	end
	
	segs = [segs; closestseg];          % Build up list of segments
	selectedSegs = [selectedSegs smin]; % Remeber selected seg Nos
	
	line([closestseg(1) closestseg(3)], [closestseg(2) closestseg(4)], ...
	     'Color',[1 0 0]);
	text((closestseg(1)+closestseg(3))/2, ...
	     (closestseg(2)+closestseg(4))/2, sprintf('%d',count));

    end           
    
function r = segdist(xp,yp,seg)
    
% Function returns distance from point (xp,yp) to line defined by end
% points (x1,y1) (x2,y2)
%	
%    
% Eqn of line joining end pts (x1 y1) and (x2 y2) can be parameterised by
%
%    x*(y1-y2) + y*(x2-x1) + y2*x1 - y1*x2 = 0
%
% (See Jain, Rangachar and Schunck, "Machine Vision", McGraw-Hill
% 1996. pp 194-196)
    
    x1=seg(1);y1=seg(2);
    x2=seg(3);y2=seg(4);   
    
    y1my2 = y1-y2;                       % Pre-compute parameters
    x2mx1 = x2-x1;
    C = y2*x1 - y1*x2;
    D = norm([x1 y1] - [x2 y2]);         % Distance between end points

    r = abs(xp*y1my2 + yp*x2mx1 + C)/D;  % Perp. distance from line to (xp,yp)

    % Correct the distance if (xp,yp) is `outside' the ends of the segment
    d1 = [xp yp]-[x1 y1];
    d2 = [xp yp]-[x2 y2];    
    if dot(d1,d2) > 0    % (xp,yp) is not `between' the end points of the
                         % segment
			 
	r = min(norm(d1),norm(d2));  % return distance to closest end
                                     % point
    end
    
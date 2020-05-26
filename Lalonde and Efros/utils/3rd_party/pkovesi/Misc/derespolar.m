%  DERESPOLAR - Desresolves image in polar coordinates.
%
%  Performs a deresolution operation on an image using Polar Coordinates
%
%  Usage:   deres = derespolar(im, nr, na, xc, yc)
%              where: nr = resolution in the radial direction
%                     na = resolution in the angular direction
%                     xc = column of polar origin (optional)
%                     yc = row of polar origin (optional)
%
% If xc and yc are omitted the polar origin defaults to the centre of the image

% Copyright (c) 1999 Peter Kovesi
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

% May 1999

% This code is horribly inefficient and needs a rewrite...

function deres = derespolar(im,nr,na,xc,yc)

  [rows,cols] = size(im);
  if nargin == 3
    xc = round(cols/2);
    yc = round(rows/2);
  end
  
  if ndims(im) == 3  % Assume colour image
    deres = uint8(zeros(size(im)));
    deres(:,:,1) = iderespolar(im(:,:,1),nr,na,xc,yc);
    deres(:,:,2) = iderespolar(im(:,:,2),nr,na,xc,yc);   
    deres(:,:,3) = iderespolar(im(:,:,3),nr,na,xc,yc);       
  else
    deres = iderespolar(im,nr,na,xc,yc);
  end
  
% Internal function that does the work
  
  function deres = iderespolar(im,nr,na,xc,yc)    
    [rows,cols] = size(im);
    
    %x = ones(rows,1) * (-cols/2 : (cols/2 - 1));  
    %y = (-rows/2 : (rows/2 - 1))' * ones(1,cols);
    
    [x,y] = meshgrid(-xc:cols-xc-1, -yc:rows-yc-1);
    
    radius = sqrt(x.^2 + y.^2);       % Matrix values contain radius from centre.
    theta = atan2(y,x);               % Matrix values contain polar angle.
    
    dr = max(max(radius))/nr;
    da = max(max(theta+pi))/na;
    
    rp = round(radius/dr)*dr;
    ra = round(theta/da)*da;
    
    rowp = yc + rp.*sin(ra);
    colp = xc + rp.*cos(ra);
    
    rowp = round(rowp);
    colp = round(colp);
    rowp = max(rowp,1); rowp = min(rowp,rows);
    colp = max(colp,1); colp = min(colp,cols);
    
    for row = 1:rows
      for col = 1:cols
	deres(row,col) = im(rowp(row,col), colp(row,col));
      end
    end

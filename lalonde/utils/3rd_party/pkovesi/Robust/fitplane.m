% FITPLANE - solves coefficients of plane fitted to 3 or more points
%
% Usage:   B = fitplane(XYZ)
%
% Where:   XYZ - 3xNpts array of xyz coordinates to fit plane to.   
%                If Npts is greater than 3 a least squares solution 
%                is generated.
%
% Returns: B   - 4x1 array of plane coefficients in the form
%                b(1)*X + b(2)*Y +b(3)*Z + b(4) = 0
%                The magnitude of B is 1.
%
% See also: RANSACFITPLANE

% Copyright (c) 2003-2005 Peter Kovesi
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

% June 2003

function B = fitplane(XYZ)
  
  [rows,npts] = size(XYZ);    
  
  if rows ~=3
    error('data is not 3D');
  end
  
  if npts < 3
    error('too few points to fit plane');
  end
  
  % Set up constraint equations of the form  AB = 0,
  % where B is a column vector of the plane coefficients
  % in the form   b(1)*X + b(2)*Y +b(3)*Z + b(4) = 0.
  
  A = [XYZ' ones(npts,1)]; % Build constraint matrix
  
  if npts == 3             % Pad A with zeros
    A = [A; zeros(1,4)]; 
  end

  [u d v] = svd(A);        % Singular value decomposition.
  B = v(:,4);              % Solution is last column of v.



  
       
       
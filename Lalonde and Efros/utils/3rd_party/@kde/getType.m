function typeS = getType(dens)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getType(P)
%  return the kernel type of the kernel density estimate P
%    One of : 'Gaussian', 'Laplacian', 'Epanetchnikov'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

switch(dens.type)
    case 0, typeS = 'Gaussian';
    case 1, typeS = 'Epanetchnikov';
    case 2, typeS = 'Laplacian';
end;

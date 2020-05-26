function display(kde)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% display(kde) -- print out whatever stuff is useful about a kernel density
%                   estimate.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

if(numel(kde) > 1)
  [r c] = size(kde);
  disp(['kde array: ' num2str(r) '-by-' num2str(c)]);
  return
end

               typeStr = 'Unknown';
if (kde.type == 0) typeStr = 'Gaussian'; end;
if (kde.type == 1) typeStr = 'Epanetchnikov'; end;
if (kde.type == 2) typeStr = 'Laplacian'; end;

if (size(kde.bandwidth,2)>2*kde.N), bwType = 'variable';
else bwType = 'uniform'; end;

disp(['Kernel Density Estimate (tree based): ']);
disp(['  ',num2str(kde.D),' dimensional; ',num2str(kde.N),' points in density']);
disp(['  made of ',typeStr,' kernels with ',bwType,' size.']);
  

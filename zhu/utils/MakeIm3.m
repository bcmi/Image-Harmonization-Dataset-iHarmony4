function [im] = MakeIm3(im)
% im3 = imread(name); 
if ismatrix(im)
   im = repmat(im,[1,1,3]);  
end
end
% MATSCII - Function to generate ASCII images
%
%  Usage: picci = matscii(im, width, gamma, filename)
%
%   im    - 2D array of image brightness colours.
%           Image can be grey scale or colour.
%   width - desired width of resulting character image.
%   gamma    - optional gamma value to enhance contrast,
%              gamma > 1 increases contrast, < 1 decreases contrast.
%   filename - optional filename in which to save the result.
%
%   picci - the resulting 2D array of characters.
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

% September 2000
% August    2005  tweaks for Octave
% September 2005  RBG conversion error fixed (thanks to Firas Zeineddine)

function picci = matscii(im, width, gamma, filename)

% ASCII grey scale

%g = '$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\|()1{}[]?-_+~<>i!lI;:,"^`''. ';
g = '#8XOHLTI)i=+;:,. ';     % This seems to be a better `grey scale'
gmax = length(g);

charAspect = 0.55;           % Width/height aspect ratio of characters

if nargin <=2
  gamma = 1;                 % Default gamma value
end

im = double(im);

if ndims(im) == 3  % We have a colour image
  im = (im(:,:,1) + im(:,:,2) + im(:,:,3))/3;   % Grey value = (R+G+B)/3
end

[rows, cols] = size(im);
scale = width/cols;

rows = round(charAspect * scale * rows);   % Rescaled rows and cols values
cols = round(scale * cols);

im = normalise(im).^gamma;         % Rescale range 0-1 and apply gamma

im = imresize(im, [rows, cols]);      
%im = myrescale(im, [rows, cols]); % Use this if you do not have the image
                                   %toolbox

im = round(im*(gmax-1) + 1);       % Rescale to range 1..gmax and round to ints.

picci = char(zeros(rows,cols));    % Preallocate memory for output image.

for r = 1: rows
  for c = 1:cols
    picci(r,c) = g(im(r,c));
  end
end

if nargin == 4    % we have a filename
  [fid, msg] = fopen(filename,'wt');
  error(msg);
  for r = 1: rows
   fprintf(fid,'%s\n',picci(r,:));
  end
  fclose(fid);
end



%-------------------------------------------------------------------
% Internal function to rescale an image so that this code
% does not require the image processing toolbox to run.
%-------------------------------------------------------------------

function newim = myrescale(im,  newRowsCols)

[rows,cols] = size(im);
newrows = newRowsCols(1);
newcols = newRowsCols(2);

rowScale = (newrows-1)/(rows-1);     % Arrays start at 1 rather than 0
colScale = (newcols-1)/(cols-1);

newim = zeros(newrows, newcols);

% For each pixel in the final image find where that pixel `came from'
% in the source image - use this as the scaled image value
% Scaling eqns account for the fact that MATLAB arrays start at 1 rather than 0

for r = 1: newrows
  for c = 1: newcols

   sourceRow = round((r-1)/rowScale + 1);
   sourceCol = round((c-1)/colScale + 1);

   newim(r,c) = im(sourceRow, sourceCol);

  end
end


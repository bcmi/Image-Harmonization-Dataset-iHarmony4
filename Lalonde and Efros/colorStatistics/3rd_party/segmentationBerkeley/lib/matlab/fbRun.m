function [fim] = fbRun(fb,im)
% function [fim] = fbRun(fb,im)
%
% Run a filterbank on an image with reflected boundary conditions.
%
% See also fbCreate,padReflect.
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% March 2003

% find the max filter size
maxsz = max(size(fb{1}));
for i = 1:numel(fb),
  maxsz = max(maxsz,max(size(fb{i})));
end

% pad the image 
r = floor(maxsz/2);
impad = padReflect(im,r);

% run the filterbank on the padded image, and crop the result back
% to the original image size
fim = cell(size(fb));
for i = 1:numel(fb),
  if size(fb{i},1)<50,
    fim{i} = conv2(impad,fb{i},'same');
  else
    fim{i} = fftconv2(impad,fb{i});
  end
  fim{i} = fim{i}(r+1:end-r,r+1:end-r);
end

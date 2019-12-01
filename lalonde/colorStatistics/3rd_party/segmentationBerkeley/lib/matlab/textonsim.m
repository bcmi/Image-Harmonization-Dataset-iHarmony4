function tsim = textonsim(fb,tex)
% function tsim = textonsim(fb,tex)
%
% Compute texton dis-similarity matrix.  The dis-similarity between
% two textons is given by their L1 difference run through an
% exponential.
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% April 2003
tim = visTextons(tex,fb);
ntex = size(tex,2);
tsim = zeros(ntex);
for i = 1:ntex,
  for j = 1:ntex,
    tsim(i,j) = sum(sum(abs(tim{i}-tim{j})));
  end
end
sigma = 0.25*max(tsim(:));
tsim = 1 - exp(-tsim/sigma);
tsim = tsim / max(tsim(:));

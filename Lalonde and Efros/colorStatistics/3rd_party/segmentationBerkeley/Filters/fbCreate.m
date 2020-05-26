function [fb] = fbCreate(numOrient,startSigma,numScales,scaling,elong)
% function [fb] = fbCreate(numOrient,startSigma,numScales,scaling,elong)
%
% Create a filterbank containing numOrient even and odd-symmetric
% filters and one center-surround filter at numScales scales.
%
% The even-symmetric filter is a Gaussian second derivative.
% The odd-symmetric filter is its Hilbert transform.
%
% See also oeFilter, csFilter, fbRun.
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% March 2003

if nargin<3, numScales = 1; end
if nargin<4, scaling = sqrt(2); end
if nargin<5, elong = 3; end
support = 3;

fb = cell(2*numOrient,numScales);
for scale = 1:numScales,
  sigma = startSigma * scaling^(scale-1);
  for orient = 1:numOrient,
    theta = (orient-1)/numOrient * pi;
    fb{2*orient-1,scale} = oeFilter(sigma*[elong 1],support,theta, 2,0);
    fb{2*orient,scale} = oeFilter(sigma*[elong 1],support,theta,2,1);
  end
  %fb{2*numOrient+1,scale} = csFilter(sigma*[3 1],support);
end

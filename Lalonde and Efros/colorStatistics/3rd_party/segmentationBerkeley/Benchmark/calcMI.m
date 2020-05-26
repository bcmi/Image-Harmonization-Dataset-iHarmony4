function [mi] = calcMI(joint)
% function [mi] = calcMI(joint)
%
% Given a 2D joint distribution, compute the mutual information
% between the distribution's two variables.  The mutual information is
% non-negative.
%
% The mutual information is equal to the Kullback-Liebler divergence
% between the joint distribution j and the product of marginals
% distribution p, i.e. mi = sum(j*log(j/p)).
%
% David Martin <dmartin@eecs.berkeley.edu>
% January 2003

if ndims(joint)~=2,
  error('joint must have 2 dimensions');
end

% normalize to get a probability distribution
joint = joint / sum(joint(:));

% calculate produce of marginals distribution
m1 = sum(joint,1);
m2 = sum(joint,2);
prod = m2 * m1;

% calculate mi
mi = joint .* log((eps+joint)./(eps+prod));
mi = sum(mi(:));

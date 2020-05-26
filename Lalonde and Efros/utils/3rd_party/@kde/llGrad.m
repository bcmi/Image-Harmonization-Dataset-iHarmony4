function [err1, err2] = llGrad(p1,p2,type,tolGrad,tolEval)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [err1,err2] = llGrad(p1, p2, type [, tolGrad ,tolEval])
%
%    Compute the gradient with respect to the means of p1,p2 of the
%       average log-likelihood of p1 evaluated at the locations of p2
%       (p1=p2 => gradient of a resubstitution estimate of negentropy)
%    type: what to take gradient with respect to.
%          0 = means, 1 = bw (variance), 2=weights
%    tolGrad is an acceptable error tolerance on the gradient values
%    tolEval is a *percent* tolerance on the evaluation done as a
%       subroutine in the calculation; it should be tight enough to allow
%       tolGrad to be achieved but beyond that, larger => faster.
%
% Specifically, using the resubstition estimate
%    \hat H = \sum_j v_j \log \sum_i w_i K(x_i - y_j)
% The outputs are
%    err1(:,i) = \sum_j v_j 1/p(y_j) dp(y_j)/dx_i = E_y[ 1/p dp/dx_i ] 
%    err2(:,j) = v_j 1/p(y_j) p'(y_j) 
%
% Note: [err1,err2] = llGrad(p1, type [, tolGrad ,tolEval]) computes the leave-
%   one-out resub. estimate, similar to llGrad(p1,p1,type...)
%
% Some useful estimates which can be made using this function:
%
% ENTROPY GRADIENT
%    [err1, err2] = llGrad(p,p,1e-3,1e-3);
%    p -= (err1 + err2)    moves p in the direction of increasing entropy
%
% KL-DIVERGENCE GRADIENT
%    [errXX1, errXX2] = llGrad(p1,p1,1e-3,1e-3);
%    [errXYY, errXYX] = llGrad(p2,p1,1e-3,1e-3); 
%    err1 = (errXX1 + errXX2 - errXYX);
%    err2 = (-errXYY);
%    p1 += err1, p2 += err2  moves p1,p2 in the direction of increasing KLDiv
%
% See also:  klGrad, miGrad, entropyGrad, adjustPoints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

%#mex
error('MEX-file kde/llGrad not found -- please recompile if necessary');

% Incorrect:  Mean shift corresponds to an estimate of 1/p(y) p'(y) where
%    p'(y) is computed using the Epan. kernel while p(y) is computed using
%    a uniform kernel with the same support.  This does *not* correspond to
%    the derivative of log-likelihood for any KDE (that I know of)
%
% MEAN-SHIFT
%    For equal weight uniform bandwidth Epan. kernel densities, 
%      the mean shift algorithm (Comaniciu '99) is given by
%    [err1, err2] = llGrad(p,p,1e-3,1e-3);
%    p += .5*getNpts(p)*getBW(p,1)^2 * err2
%

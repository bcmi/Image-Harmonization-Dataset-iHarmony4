%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [basis, coeff, meanData]=PCA(rawmat, varpercent)
%   Computes PCA for a given input observation matrix.
% 
% Input parameters:
%  - rawmat: nbDims*nbPoints matrix
%
% Output parameters:
%  - basis: The PCA basis
%  - coeff: The PCA coefficients
%  - meanData: The mean of the data such that
%      data = meanData + basis*coeff
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [basis, coeff, meanData]=PCA(rawmat, varpercent)

meanData = mean(rawmat,2);
rawmat = rawmat - repmat(meanData, [1 size(rawmat,2)]);

[U,S] = svd(rawmat,'econ');

cumSumNorm = cumsum(diag(S.^2)) ./ sum(diag(S.^2));

if nargin == 2
    i = find(cumSumNorm >= varpercent);
    basis = U(:,1:i(1));
else
    basis = U;
end
coeff = basis'*rawmat;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function v = ind2subv(siz,ndx)
%   Vectorized version of ind2sub
% 
% Input parameters:
%   Same as ind2sub
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function v = ind2subv(siz,ndx)[out{1:length(siz)}] = ind2sub(siz,ndx);
v = cell2mat(out);
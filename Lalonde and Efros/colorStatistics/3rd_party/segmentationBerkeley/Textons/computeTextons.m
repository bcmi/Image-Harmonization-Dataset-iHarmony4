function [map,textons] = computeTextons(fim,k)
% function [map,textons] = computeTextons(fim,k)

d = numel(fim);
n = numel(fim{1});
data = zeros(d,n);
for i = 1:d,
  data(i,:) = fim{i}(:)';
end

[map,textons] = kmeansML(k,data,'maxiter',30,'verbose',1);
[w,h] = size(fim{1});
map = reshape(map,w,h);



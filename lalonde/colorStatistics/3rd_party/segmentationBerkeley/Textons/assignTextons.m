function [map] = assignTextons(fim,textons)
% function [map] = assignTextons(fim,textons)

d = numel(fim);
n = numel(fim{1});
data = zeros(d,n);
for i = 1:d,
  data(i,:) = fim{i}(:)';
end

d2 = distSqr(data,textons);
[y,map] = min(d2,[],2);
[w,h] = size(fim{1});
map = reshape(map,w,h);

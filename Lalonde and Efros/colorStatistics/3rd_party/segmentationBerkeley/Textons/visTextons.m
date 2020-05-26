function [tim,perm] = visTextons(textons,fb)
% function [tim,perm] = visTextons(textons,fb)

if size(textons,1) ~= numel(fb),
  error('size(textons,1) ~= numel(fb)');
end

[d,k] = size(textons);

% find the max filter size
maxsz = max(size(fb{1}));
for j = 1:d,
  maxsz = max(maxsz,max(size(fb{j})));
end

% compute the linear combinations of filters
tim = cell(k,1);
for i = 1:k,
  tim{i} = zeros(maxsz);
  for j = 1:d,
    f = fb{j} * textons(j,i);
    off = (maxsz-size(f,1))/2;
    tim{i}(1+off:end-off,1+off:end-off) = tim{i}(1+off:end-off,1+off:end-off) + f;
  end
end

% computer permutation order for decreasing L1 norm
norms = zeros(k,1);
for i = 1:k,
  norms(i) = sum(sum(abs(tim{i})));
end
[y,perm] = sort(norms);
perm = flipud(perm);

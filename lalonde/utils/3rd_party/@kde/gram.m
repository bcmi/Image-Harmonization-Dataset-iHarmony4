function G = gram(p)
%
% Compute the Gram matrix of the kernel centers in p, under the distance metric determined
%  by the kernel sizes of the points; G(i,j) = (p_i*p_j')/bw_i
%
pts = getPoints(p); N = getNpts(p); d = getDim(p);
G = zeros(N);
for i=1:N
  dummy=pts(:,i:end)-repmat(pts(:,i),1,N-i+1);
  G(i:N,i) =-0.5*sum(dummy.^2 ./ getBW(p,i:N).^2 + log(getBW(p,i:N).^2) ,1)';
  G(i,i:N) =-0.5*sum(dummy.^2 ./ repmat(getBW(p,i).^2,[1,N-i+1]) + repmat(log(getBW(p,i).^2) ,[1,N-i+1]) ,1);
end
G = exp(G) ./ (2*pi)^(d/2);

function pb2 = upsamplepb(pb,sz2)

h = size(pb,1);
w = size(pb,2);
h2 = sz2(1);
w2 = sz2(2);

pb2 = zeros(sz2);
for x = 1:w,
  for y = 1:h,
    if pb(y,x)==0, continue; end
    x2 = 1+round((x-1)*w2/w);
    y2 = 1+round((y-1)*h2/h);
    pb2(y2,x2) = pb(y,x);
  end
end



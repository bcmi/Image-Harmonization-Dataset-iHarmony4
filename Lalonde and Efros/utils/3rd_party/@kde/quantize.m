function p = quantize(p,R,minV,maxV,minS,maxS)
%
% p = quantize(p,R,type) -- "quantize" elements of KDE p to R bits
%

%p.centers   = round(1000*p.centers)/1000;
%p.means     = round(1000*p.means)/1000;
%p.ranges    = round(1000*p.ranges)/1000;
%p.bandwidth = ceil(10000*p.bandwidth)/10000;

p.centers   = roundVals(p.centers  ,minV,maxV,R);
p.means     = roundVals(p.means    ,minV,maxV,R);
p.ranges    = roundVals(p.ranges   ,minV,maxV,R);
p.bandwidth = roundVals(p.bandwidth,minS,maxS,R);


function x = roundVals(x,minV,maxV,R)
 scale = 2^R ./ repmat(maxV-minV,size(x)./size(maxV));
 minV = repmat(minV,size(x)./size(minV)); x = x - minV; x = max(x,0);
 x = x .* scale; x = min(round(x),2^R-1); x = x./scale; x = x + minV;


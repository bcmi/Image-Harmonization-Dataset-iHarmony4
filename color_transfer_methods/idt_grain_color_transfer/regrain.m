%
%  regraining post-process to match colour of IR and gradient of I0
%
%   IRR = degrain(I_original, I_graded, [smoothness]);
%
%   the smoothness (default=1, smoothness>=0) sets the fidelity of the 
%   original gradient field. e.g. smoothness = 0 implies IRR = I_graded.
%
%  (c) F. Pitie 2007
%
%  see reference:
%     Automated colour grading using colour distribution transfer. (2007)
%     Computer Vision and Image Understanding.
%
%  note: this implementation follows a simple top-down approach
%        with jacobi iterations.
%
function IRR = regrain(I0, IR, varargin)

numvarargs = length(varargin);
if numvarargs > 1
    error('regrain:TooManyInputs', ...
        'requires at most 1 optional input');
end

optargs = {1};
optargs(1:numvarargs) = varargin;
[smoothness] = optargs{:};

IRR = I0;
[IRR] = regrain_rec(IRR, I0, IR, [4 16 32 64 64 64 ], smoothness, 0);

end

function [IRR] = solve(IRR, I0, IR, nbits, smoothness, level)

hres = size(I0,2);
vres = size(I0,1);
K = size(I0,3);

y0 = 1:vres;
y1 = 1:vres;
y2 = [2:vres vres];
y3 = 1:vres;
y4 = [1 1:vres-1];

x0 = 1:hres;
x1 = [2:hres hres];
x2 = 1:hres;
x3 = [1 1:hres-1];
x4 = 1:hres;

G0 = I0;
G0x = (G0(:,[2:end end], :) - G0(:,[1 1:end-1], :));
G0y = (G0([2:end end], :, :) - G0([1 1:end-1], :, :));
dI = sqrt(sum(G0x.^2 + G0y.^2, 3));

h = 2^(-level);
psi = min(256*dI/5, 1);
phi = 30./(1 + 10*dI/max(smoothness, eps))*h;

phi1 = (phi(y1,x1) + phi(y0, x0))/2;
phi2 = (phi(y2,x2) + phi(y0, x0))/2;
phi3 = (phi(y3,x3) + phi(y0, x0))/2;
phi4 = (phi(y4,x4) + phi(y0, x0))/2;

rho = 1/5;
for i=1:nbits
    den =  psi + phi1 + phi2 + phi3 + phi4;
    
    num =  repmat(psi, [1 1 K]).*IR   ...
        + repmat(phi1, [1 1 K]).*(IRR(y1,x1,:) - I0(y1,x1,:) + I0) ...
        + repmat(phi2, [1 1 K]).*(IRR(y2,x2,:) - I0(y2,x2,:) + I0) ...
        + repmat(phi3, [1 1 K]).*(IRR(y3,x3,:) - I0(y3,x3,:) + I0) ...
        + repmat(phi4, [1 1 K]).*(IRR(y4,x4,:) - I0(y4,x4,:) + I0);
    
    IRR = num./repmat(den + eps, [1 1 K]) .* (1-rho) + rho.*IRR;
end

end

function [IRR] = regrain_rec(IRR, I0, IR, nbits, smoothness, level)

hres = size(I0,2);
vres = size(I0,1);
vres2 = ceil(vres/2);
hres2 = ceil(hres/2);

if (length(nbits) > 1 && hres2 > 20 && vres2 > 20)
    I02 = imresize(I0, [vres2 hres2], 'bilinear');
    IR2 = imresize(IR, [vres2 hres2], 'bilinear');
    IRR2 = imresize(IRR, [vres2 hres2], 'bilinear');
    [IRR2] = regrain_rec(IRR2, I02, IR2, nbits(2:end), smoothness, level+1);
    IRR = imresize(IRR2, [vres hres], 'bilinear');
end

IRR = solve(IRR, I0, IR, nbits(1), smoothness, level);

end

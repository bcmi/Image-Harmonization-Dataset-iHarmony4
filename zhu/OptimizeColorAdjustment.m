function out = OptimizeColorAdjustment(src, tgt, mask, opts, net)
% check
assert( size(src,1)==size(tgt,1) && size(src,2)==size(tgt,2), 'inconsitent image size (source, target)'); 
assert( size(src,1)==size(mask,1) && size(src,2)==size(mask,2), 'inconsitent image size (source, target)'); 

% get paramters
w = opts.WEIGHT; 
seeds = opts.SEEDS; 
ub = opts.UPEER_BOUND;
lb = opts.LOWER_BOUND; 
isSoft = opts.IS_SOFT; 

% convert matlab image to caffe data format
src_t = CaffeTransform(src);
tgt_t = CaffeTransform(tgt);

if isSoft
    mask=im2single(mask);
    m = MakeIm3(mask);
else
    softmask = FeatherMask(mask(:,:,1), 3); 
    m = MakeIm3(im2single(softmask));
end

mask_t = CaffeTransform(m);

% set optimization
f = @(x)funColor(x,src_t,tgt_t,mask_t,w,net);
options = optimoptions('fmincon', 'TolX', 1e-3,'GradObj','on','Hessian','lbfgs', 'Display','Off');

nSeeds = numel(seeds);
fprintf('number of seeds = %d\n', nSeeds);
xs = cell(nSeeds,1);
fvals = zeros(nSeeds,1);

% solver
global nIters;
global fmin;
for n = 1 : nSeeds    
    nIters = 0;
    fmin = 1e10;
    seed = seeds(n);
%     disp(seed);
    x0 = [seed,seed,seed,0,0,0];
    [x, fval] = fmincon(f,x0,[],[],[],[], lb,ub,{},options);
    xs{n} = x;
    fvals(n) = fval;
    fprintf('seed = %3.3f, fval = %3.3f\n', seed,fval);
end


[fval_min,id_min] = min(fvals);
fprintf('best seed = %3.3f, fval = %3.3f\n', seeds(id_min), fval_min);

f0 = funColor([1,1,1,0,0,0], src_t, tgt_t, mask_t,w, net);
fprintf('f0 = %3.3f\n', f0);


out.best_seed = id_min;
out.opts = opts; 
out.fvals = fvals;
out.xs = xs;
out.f0 = f0;
out.final_result = FinalResult(src, tgt, mask, xs{id_min});
out.cut_and_paste = FinalResult(src, tgt, mask, [1,1,1,0,0,0]); 

end


function [alphaMask] = FeatherMask(mask, seRadius)
sz = [size(mask, 1), size(mask, 2)]; 
seErode = strel('disk', seRadius); 

objErode = double(imerode(mask, seErode));
distObj = bwdist(objErode);
distBg = bwdist(ones(sz) - logical(mask));
alphaMask = ones(sz) - distObj ./ (distObj + distBg);
end


function [im_data] = CaffeTransform(im)
IMAGE_DIM = 224;
im_data = im(:, :, [3, 2, 1]);  % permute channels from RGB to BGR
im_data = permute(im_data, [2, 1, 3]);  % flip width and height
im_data = single(im_data);  % convert from uint8 to single
im_data = imresize(im_data, [IMAGE_DIM IMAGE_DIM]);  % resize im_data
end

function [out] = FinalResult(src,tgt,mask,x)
sz = [size(mask,1),size(mask,2)]; 
src = im2double(imresize(src,sz));
tgt = im2double(imresize(tgt,sz));
mask = im2double(mask);

gain = x(1:3);
bias = x(4:6);

for c = 1 : 3
    tmp = src(:,:,c);
    tmp  = tmp * gain(4-c)+bias(4-c); % rgb to bgr
    src(:,:,c) = tmp;
end

out = src.* mask +tgt.* (1-mask);
out = max(0,min(1,out));
end


function [f,gx] = funColor(x, src_t, tgt_t, mask_t,weight, net)
h = size(src_t,1);
w = size(src_t,2);
bias = repmat(reshape(single(x(1:3)),[1,1,3]),[h,w,1]);
gain = repmat(reshape(single(x(4:6)),[1,1,3]),[h,w,1]);
recolor_t = src_t .* bias + 255.0 * gain;
composite = recolor_t .* mask_t+tgt_t.* (1-mask_t);

composite = max(0,min(255,composite));
mean_pix = single([103.939, 116.779, 123.68]);
composite = composite - repmat(reshape(mean_pix,[1,1,3]), [h,w,1]);
res = net.forward({composite,single(1)});
f_cnn = double(res{1});
% fc8 = net.blobs('fc8_color').get_data();
net.backward_prefilled();
data_diff = net.blobs('data').get_diff();
gx = zeros(size(x));

diff = data_diff.*mask_t;
gx(1:3) = sum(sum(diff.*src_t,1),2);
gx(4:6) = sum(sum(diff*255.0,1),2);

% compute reg term
if weight > 0
    N = sum(mask_t(:));
    % normalize weight by the number of pixels in the mask
    w1 = weight / (255.^2 * N);
    src1 = src_t(:,:,1); src1 = src1(:);
    src2 = src_t(:,:,2); src2 = src2(:);
    src3 = src_t(:,:,3); src3 = src3(:);

    ratio = min(20,mean(src_t(:).^2) ./ (mean([mean((src1-src2).^2), mean((src2-src3).^2), mean((src3-src1).^2)]))); % add a small constant
 
    w2 = w1 * ratio;

    % difference between recolored objectg and original object
    color_diff = (recolor_t-src_t).* mask_t;
    f_dif = 0.5 * w1 * sum(color_diff(:).^2);
    gx(1:3) = gx(1:3) + squeeze(w1 * sum(sum(src_t.*color_diff,1),2))';
    gx(4:6) = gx(4:6) + squeeze(w1 * sum(sum(255.*color_diff,1),2))';

    cd1 = color_diff(:,:,1); cd1 = cd1(:);
    cd2 = color_diff(:,:,2); cd2 = cd2(:);
    cd3 = color_diff(:,:,3); cd3 = cd3(:);
    
    f_cross = 0.5 * w2 *  (sum((cd1-cd2).^2)  + sum((cd2-cd3).^2)+sum((cd3-cd1).^2));
    gx_cross1 = cd1*2-cd2-cd3;
    gx_cross2 = cd2*2-cd1-cd3;
    gx_cross3 = cd3*2-cd1-cd2;
    gx(1) = gx(1) + w2 * sum(gx_cross1.*src1);
    gx(2) = gx(2) + w2 * sum(gx_cross2.*src2);
    gx(3) = gx(3) + w2 * sum(gx_cross3.*src3);
    gx(4) = gx(4) + w2 * 255.0 * sum(gx_cross1);
    gx(5) = gx(5) + w2 * 255.0 * sum(gx_cross2);
    gx(6) = gx(6) + w2 * 255.0 * sum(gx_cross3);

    f = f_cnn + f_dif + f_cross;
else
    f = f_cnn;
end

global nIters;
nIters = nIters +1;
f = double(f);
gx = double(gx);
end
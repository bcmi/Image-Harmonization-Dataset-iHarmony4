function new_im1 = rescale_image(im1, im2, region_mask1, region_mask2)

% get rid of NaN and -Inf cases, which usually happens to lab images
mask1 = ~isnan(im1) & (im1~=-Inf);
mask1 = mask1(:,1).*mask1(:,2).*mask1(:,3).*region_mask1; 
valid_im1 = im1(mask1>0,:);

mask2 = ~isnan(im2) & (im2~=-Inf);
mask2 = mask2(:,1).*mask2(:,2).*mask2(:,3).*region_mask2;  
valid_im2 = im2(mask2>0,:);

% mean-std conversion
mean1 = mean(valid_im1);
std1 = std(valid_im1);
mean2 = mean(valid_im2);
std2 = std(valid_im2);

% update the whole im1 but not only the overlapped area
[N,~] = size(im1);
new_im1 = im1 - repmat(mean1, N, 1);  % centralize
new_im1 = repmat(std2./std1, N, 1).*new_im1;
new_im1 = new_im1 + repmat(mean2, N, 1);     


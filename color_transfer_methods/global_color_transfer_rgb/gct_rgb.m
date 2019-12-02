function final_im1=gct_rgb(img_tgt, img_ref, mask_tgt, mask_ref)

%get the segmented object in target iamge and reference image
im1=(uint8(img_tgt)); 
im2=(uint8(img_ref)); 

% reshape images
[nr1,nc1,nd1] = size(im1);
if nd1==1
    new1=zeros(nr1,nc1,3);
    for i=1:3
        new1(:,:,i)=im1;
    end
    im1=new1;
end
im1 = reshape(double(im1), nr1*nc1, 3);
% im1 = im1/255;

[nr2,nc2,nd2] = size(im2);
if nd2==1
    new2=zeros(nr2,nc2,3);
    for i=1:3
        new2(:,:,i)=im2;
    end
    im2=new2;
end
im2 = reshape(double(im2), nr2*nc2, 3);
% im2 = im2/255;
m1 = reshape(double(mask_tgt), nr1*nc1, 1);
m2 = reshape(double(mask_ref), nr2*nc2, 1);

% mean-covariance conversion
new_im1 = transform_image(im1,im2,m1,m2);
new_im1 = reshape(uint8(new_im1), nr1, nc1, 3);

%get the background mask
fg = mask_tgt; bg = 1 - mask_tgt;

%final image = color-transfered foreground and original background
final_im1=new_im1.*fg+img_tgt.*bg;









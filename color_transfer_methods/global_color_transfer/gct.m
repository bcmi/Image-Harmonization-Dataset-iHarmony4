function final_im1_1 = gct(img_tgt, img_ref, mask_tgt, mask_ref)

im1=(uint8(img_tgt));
im2=(uint8(img_ref)); 

% project images into lab space
[nr1,nc1,nd1] = size(im1);
if nd1==1
    new1=zeros(nr1,nc1,3);
    for i=1:3
        new1(:,:,i)=im1;
    end
    im1=new1;
end
im1 = reshape(double(im1), nr1*nc1, 3);
im1_rgb = im1/255;  % convert rgb values to [0,1] range
im1_lab = rgb2lab(im1_rgb);


[nr2,nc2,nd2] = size(im2);
if nd2==1
    new2=zeros(nr2,nc2,3);
    for i=1:3
        new2(:,:,i)=im2;
    end
    im2=new2;
end
im2 = reshape(double(im2), nr2*nc2, 3);
im2_rgb = im2/255;  % convert rgb values to [0,1] range
im2_lab = rgb2lab(im2_rgb);


m1 = reshape(double(mask_tgt), nr1*nc1, 1);
m2 = reshape(double(mask_ref), nr2*nc2, 1);

% mean-std conversion
new_im1_lab = rescale_image(im1_lab, im2_lab, m1, m2);

% convert back into rgb space
new_im1_1 = lab2rgb(new_im1_lab);
new_im1_1 = reshape(uint8(new_im1_1*255), nr1,nc1,3);

%get the background mask
fg = uint8(mask_tgt); 
bg = 1 - uint8(mask_tgt);

%final image = color-transfered foreground and original background
final_im1_1=new_im1_1.*fg+uint8(img_tgt).*bg;
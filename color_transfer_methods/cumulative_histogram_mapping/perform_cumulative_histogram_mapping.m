function new_im1 = perform_cumulative_histogram_mapping(im1, im2, region_mask1, region_mask2)   

% perform cumulative histogram mapping that maps the luminance/color of im2 to
% im1
%
% Wei Xu
% Oct. 2009

im1 = uint8(im1);
im2 = uint8(im2);

% project images into yCbCr space
[nr1,nc1,nd1] = size(im1);
im1_ycbcr = rgb2ycbcr(im1);
im1_ycbcr = reshape(double(im1_ycbcr), nr1*nc1, nd1);

[nr2,nc2,nd2] = size(im2);
im2_ycbcr = rgb2ycbcr(im2);
im2_ycbcr = reshape(double(im2_ycbcr), nr2*nc2, nd2);

region_mask1 = region_mask1(:);
region_mask2 = region_mask2(:);

% luminance transfer
new_im1_ycbcr = im1_ycbcr;
edges{1} = [16-0.5:1:235+0.5];   % according to rgb2ycrcb(), y in [16, 235]
edges{2} = [16-0.5:1:240+0.5];   % cb in [16, 240]
edges{3} = [16-0.5:1:240+0.5];   % cr in [16, 240]
[new_ycbcr, chist_im2, chist_im1, map, M] = cumulative_histogram_mapping(im1_ycbcr(region_mask1,:), im2_ycbcr(region_mask2,:), edges);
new_im1_ycbcr(region_mask1,:) = new_ycbcr;
new_im1 = ycbcr2rgb(uint8(reshape(new_im1_ycbcr,nr1,nc1,nd1)));    
% bgm=uint8(fg2bg_mask(region_mask1));
% bgm = reshape(bgm,nr1,nc1,1);
% %fprintf('size of bgm: %d\n',size(bgm));
% new_im1 = new_im1 .* uint8(reshape(region_mask1,nr1,nc1,1)) + im1 .* bgm; 

% % visualization
% figure, subplot(4,5,1), imshow(im1), title('tgt. image');
% subplot(4,5,2), imshow(im2), title('src. image');
% subplot(4,5,3), imshow(new_im1), title('converted tgt.');
% 
% subplot(4,5,6), imshow(reshape(uint8(im1_ycbcr(:,1)),nr1,nc1)), title('Y of tgt.');
% subplot(4,5,7), imshow(reshape(uint8(im2_ycbcr(:,1)),nr2,nc2)), title('Y of src.');
% subplot(4,5,8), imshow(reshape(uint8(new_im1_ycbcr(:,1)),nr1,nc1)), title('Y of converted');
% subplot(4,5,9), plot(chist_im1{1}), axis([16 235 0.0 1.0]), title('chist of Y of ref');
% subplot(4,5,10), plot(chist_im2{1}), axis([16 235 0.0 1.0]), title('chist of Y of src.');
% 
% subplot(4,5,11), imshow(reshape(uint8(im1_ycbcr(:,2)),nr1,nc1)), title('Cb of ref.');
% subplot(4,5,12), imshow(reshape(uint8(im2_ycbcr(:,2)),nr2,nc2)), title('Cb of src.');
% subplot(4,5,13), imshow(reshape(uint8(new_im1_ycbcr(:,2)),nr1,nc1)), title('Cb of converted');
% subplot(4,5,14), plot(chist_im1{2}), axis([16 240 0.0 1.0]), title('chist of Cb of ref');
% subplot(4,5,15), plot(chist_im2{2}), axis([16 240 0.0 1.0]), title('chist of Cb of src.');
% 
% subplot(4,5,16), imshow(reshape(uint8(im1_ycbcr(:,3)),nr1,nc1)), title('Cr of ref.');
% subplot(4,5,17), imshow(reshape(uint8(im2_ycbcr(:,3)),nr2,nc2)), title('Cr of src.');
% subplot(4,5,18), imshow(reshape(uint8(new_im1_ycbcr(:,3)),nr1,nc1)), title('Cr of converted');
% subplot(4,5,19), plot(chist_im1{3}), axis([16 240 0.0 1.0]), title('chist of Cr of ref');
% subplot(4,5,20), plot(chist_im2{3}), axis([16 240 0.0 1.0]), title('chist of Cr of src.');

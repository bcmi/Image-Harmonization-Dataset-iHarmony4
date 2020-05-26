function  [Mask, I_bright, I_lCntrst, I_cct, I_S, I_H] = prepImg_input(oriMask, oriI )
%% INPUT
%  oriMask     1 channel image (0~1)
%  oriImg      3 channel image (0~1)  not inverse Gamma yet

%% %% %% %% Crop the original Image and Mask %% %% %% %%

% Find a Local mask for background
BW = im2bw(oriMask, 0.5);  % binary mask, a logical array; thrshhold in 0~1

STATS = regionprops(BW, 'BoundingBox');
bndbx       = STATS.BoundingBox;
cx = bndbx(1);      cy  = bndbx(2);       % x, L->R; y, up->down, upper-left corner of bndbox
xwid = bndbx(3);    ywid  = bndbx(4);     % size of the bounding box 

len_crop = 3;  % len x len bndbox around the FG is considered as BG.
sx = cx - (len_crop-1)/2*xwid;  sy = cy - (len_crop-1)/2*ywid;    % upper-left corner 
tx = cx + (len_crop+1)/2*xwid;  ty = cy + (len_crop+1)/2*ywid;    % bottom-right corner

sx = round(max(sx,1));   sy = round(max(sy,1));
tx = round(min(tx,size(BW,2)));   ty = round(min(ty,size(BW,1)));

%figure; imshow(BW); hold on;
%rectangle('Position', [sx,sy,tx-sx,ty-sy],'EdgeColor','y');

% Crop
Mask = oriMask(sy:ty, sx:tx);
I    = oriI(sy:ty, sx:tx, :);
%figure; imshow(Mask); 
%figure; imshow(I); 



%% %% %% %% Load Fg and Bg and process  %% %% %% %%
I_GammaInv = GammaInv( I );   %imadjust(I, [0 0 0;1 1 1], [0 0 0;1 1 1], 2.2); % inverse Gamma (LDR->HDR)

sigma = min(size(I,1), size(I,2))/1024;  % given min(wid,ht)=1024, sigma = 1
fsz = ceil(sigma*2)*2+1;
filter = fspecial('gaussian', fsz, sigma);
I_ready = imfilter(I_GammaInv, filter, 'replicate');      % ** The final ready-to-use input **
%figure; imshow(I_ready);

%% Calc different image projections
% Luminance Channel  
I_bright        = I_ready(:,:,1)*0.21 + I_ready(:,:,2)*0.72 + I_ready(:,:,3)*0.07;  % Luminance Y, xyY<-- sRGB
% figure; imshow(I_bright);
% I_bb = I_bright;
% I_bb(I_bb<=0.013) = 1.0;
% figure; imshow(I_bb);

% Luminosity Local Contrast
I_lCntrst       = calcLocalCntrst_Bright(I_bright);
%figure; imshow(I_lCntrst / max(max(I_lCntrst)) );

% Color temperature in mired
I_cct           = calcCCTimg( I_ready );
%figure; imshow(I_cct /max(max(I_cct)) );

% HSV space
[I_H, I_S, I_V]           = rgb2hsv(I_ready);  % H, S, V, 0-1. H is periodic in [0,1]
% figure;
% subplot(2,2,1), imshow(I_H);    
% subplot(2,2,2), imshow(I_S);
% subplot(2,2,3), imshow(I_V);
% subplot(2,2,4), imshow(I_ready);




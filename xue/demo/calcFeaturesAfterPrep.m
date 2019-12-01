function fgbgFeatures = calcFeaturesAfterPrep(Mask, I_bright, I_lCntrst, I_cct, I_S, I_H)
% MASK:  input, 1 channel, 0-1

Mask = im2bw(Mask);
STATS = regionprops(Mask, 'BoundingBox');
bndbx       = STATS.BoundingBox;
xwid = bndbx(3);    ywid  = bndbx(4);     % size of the bounding box 

%% %% %% %% Foreground %% %% %% %% 
erodeRatio_F = 0.03;
r = floor(min(xwid, ywid)*erodeRatio_F);
se = strel('disk',r);        
Mask_F = imerode(Mask, se);
%figure; imshow(I_bright.*Mask_F);
features_F = computeFeatures(Mask_F, I_bright, I_lCntrst, I_cct, I_S, I_H);


%% %% %% %% Background %% %% %% %% 
erodeRatio_B = 0.15;
r = floor(min(xwid, ywid)*erodeRatio_B);
se = strel('disk', r);        
Mask_B = imerode(~Mask, se);
%figure; imshow(I_bright.*Mask_B);
features_B = computeFeatures(Mask_B, I_bright, I_lCntrst, I_cct, I_S, I_H);




            
%% %% %% %% OUTPUT %% %% %% %% 

fgbgFeatures        =        [ features_F ; ...    % first row
                               features_B   ...     % second row
                              ];
clear features_F;                          
clear features_B;
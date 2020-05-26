function locCntrst_I = calcLocalCntrst_Bright( b_I )
%bright image b_I, single channel, [0~1], linear mapping (GammaInv already,
%HDR), filtered

% Option 1. local std(L) / E(L), approx. to 3

% Option 2. (V1(L)-V2(L)) / V1(L), diff between Gaussion, approx. to 3

% Option 3. (L-E(L)) / E(L), i.e., dLog(L) at L=E(L), Webber's Law  (default, linear to HVS)

epsilon = (1/255)/12.92; % = 2^(-11.686)


%% Option 2
% sigma2 = min(size(b_I,1), size(b_I,2))/256;  % given min(wid,ht)=512, sigma = 1 (in pixel)
% fsz2 = ceil(sigma2*2)*2+1;
% H2 = fspecial('gaussian', fsz2, sigma2); % 7x7 sigma = 3, approx. average filtering, faster
% I2 = imfilter(b_I, H2, 'replicate');
% 
% sigma1 = sigma2 * 1.6;      %  average filter
% fsz1 = ceil(sigma1*2)*2+1;
% H1 = fspecial('gaussian', fsz1, sigma1); 
% I1 = imfilter(b_I, H1, 'replicate');
% 
% locCntrst_I = abs( (I1 - I2) ./ max(I1, epsilon) );  
% %imshow(locCntrst_I);

%% Option 3
sigma = 1.5;
fsz = ceil(sigma*2)*2+1;
H = fspecial('gaussian', fsz, sigma); % average filtering, faster
I_ave = imfilter(b_I, H, 'replicate');

locCntrst_I = abs( (b_I - I_ave) ./ max(I_ave, epsilon) );  
%imshow(locCntrst_I);


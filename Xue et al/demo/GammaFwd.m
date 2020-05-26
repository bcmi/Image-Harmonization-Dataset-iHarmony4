function I_GammaFwd = GammaFwd( I_inv )
%input, I_inv, 0~1, 3 channels, in linear HDR space
I_GammaFwd = I_inv;
I_GammaFwd(I_inv<=0.0031308) = I_inv(I_inv<=0.0031308) * 12.92;
I_GammaFwd(I_inv>0.0031308)  = I_inv(I_inv>0.0031308).^ (1/2.4) * (1+0.055) - 0.055;
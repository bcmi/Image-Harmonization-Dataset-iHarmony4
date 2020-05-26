function I_GammaInv = GammaInv(I)
% input: I 0~1, 3 channels, not Gamma corrected yet
I_GammaInv = I;
I_GammaInv(I<=0.04045) = I(I<=0.04045) / 12.92;
I_GammaInv(I>0.04045)  = ( (I(I>0.04045)+0.055)/(1+0.055) ) .^ 2.4;

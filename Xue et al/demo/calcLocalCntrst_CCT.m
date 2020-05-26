function locCntrstCCT_I = calcLocalCntrst_CCT( cct_I )
%cct image cct_I, single channel, in mired (10^6/temp), linear to HVS

% Option 1. local std(cct) approx. to 3

% Option 2. (V1(L)-V2(L)), diff between Gaussion, approx. to 3

% Option 3. (cct-E(cct)), i.e., dCCT at E(cct)  (default)

fsz = round( min(size(cct_I,1), size(cct_I,2))/55 );  % given wid=400, fsz = 7
H = fspecial('gaussian', fsz, 3.0); % sigma = 3, approx. average filtering, faster
aveI = imfilter(cct_I, H, 'replicate');

locCntrstCCT_I = abs( cct_I - aveI );
%imshow(locCntrst_I);




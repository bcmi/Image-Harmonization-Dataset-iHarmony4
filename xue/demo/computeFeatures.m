function features = computeFeatures(Mask, I_bright, I_lCntrst, I_cct, I_S, I_H)
% INPUT
%  Mask  1 channel Mask  (0~1)    
% I_bright, I_lCntrst, I_cct, I_S, I_H,   all 1 channel images

%% Parameters
mask_thrsh = 0.5;

epsilon = (1/255)/12.92; % = 2^(-11.686)
logeps = log2(epsilon);

overExp_thrsh = 0.88; % GammaInv(240/255) = 0.8714 Remove overExposed  
shdw_thrsh = GammaInv(60/255);  %= 0.0130 Remove Shadowed 

% median_cntrst = 0.015
% 1-GammaInv(245/255) = 0.0869; 1-GammaInv(118/255)/GammaInv(128/255) = 0.1607
cntrst_thrsh = 0.10;  % lowest cntrst we consider

top_ratio  = 1/1024; %robust highest end. in Photoshop, by default 0.1%
low_ratio  = 1-top_ratio;  %robust lowest end.
highlight_ratio = 1/128;   % for cct and hue

%% Luminance
I_bright        = max(I_bright, epsilon);       % prevent 0
v = sort( I_bright( Mask>=mask_thrsh ), 'descend');  % the masked out area of bg,  >= 0.5/256
logv = log2(v);                                  % difference of logv more related to contrast
logv( isnan(logv) ) = [];   % remove NaN
num = length(logv);
%disp(sprintf('num =%d', num));
clear v;


% Sparse histogram, in LOG domain!
lum_high      = mean( logv(1:floor(1+top_ratio*num)) );    % %1 quantile
lum_shdw      = mean( logv(floor(1+low_ratio*num):end) );  % %99 quantile
lum_median    = median( logv );                       % %50 quantile

% Other 1-order statistics of LOG histogram
lum_mean      = mean( logv );
lum_std       = std( logv );             
lum_skew      = skewness( logv );   
lum_kurt      = kurtosis( logv ) - 3;       % peakness, normal = 0, peaky>0, uniform<0

% Entropy
logv_norm = max(logv, logeps );    %min logv = log2( epsilon ), 
logv_norm = min(logv_norm, 0);  %max logv = log2( 1 ) = 0
logv_norm = (logv_norm - logeps) / (0-logeps) * 255;  % scale logv to 0~255   (normalized logv)
lum_entropy   = entropy( logv_norm  );         % entropy() is originally for grayscale image, 0-255


% Range (Scale) of log Histogram
lum_range         =  lum_high - lum_shdw;                                   

% Shape (percentage) of log Histogram
lum_portion_01   =  sum( logv >= lum_high-lum_range*1/20 ) / num;
lum_portion_02   =  sum( logv >= lum_high-lum_range*2/20 & logv < lum_high-lum_range*1/20  ) / num;
lum_portion_03   =  sum( logv >= lum_high-lum_range*3/20 & logv < lum_high-lum_range*2/20  ) / num;
lum_portion_04   =  sum( logv >= lum_high-lum_range*4/20 & logv < lum_high-lum_range*3/20  ) / num;
lum_portion_05   =  sum( logv >= lum_high-lum_range*5/20 & logv < lum_high-lum_range*4/20  ) / num;
lum_portion_06   =  sum( logv >= lum_high-lum_range*6/20 & logv < lum_high-lum_range*5/20  ) / num;
lum_portion_07   =  sum( logv >= lum_high-lum_range*7/20 & logv < lum_high-lum_range*6/20  ) / num;
lum_portion_08   =  sum( logv >= lum_high-lum_range*8/20 & logv < lum_high-lum_range*7/20  ) / num;
lum_portion_09   =  sum( logv >= lum_high-lum_range*9/20 & logv < lum_high-lum_range*8/20  ) / num;
lum_portion_10   =  sum( logv >= lum_high-lum_range*10/20 & logv < lum_high-lum_range*9/20  ) / num;
lum_portion_11   =  sum( logv >= lum_high-lum_range*11/20 & logv < lum_high-lum_range*10/20  ) / num;
lum_portion_12   =  sum( logv >= lum_high-lum_range*12/20 & logv < lum_high-lum_range*11/20  ) / num;
lum_portion_13   =  sum( logv >= lum_high-lum_range*13/20 & logv < lum_high-lum_range*12/20  ) / num;
lum_portion_14   =  sum( logv >= lum_high-lum_range*14/20 & logv < lum_high-lum_range*13/20  ) / num;
lum_portion_15   =  sum( logv >= lum_high-lum_range*15/20 & logv < lum_high-lum_range*14/20  ) / num;
lum_portion_16   =  sum( logv >= lum_high-lum_range*16/20 & logv < lum_high-lum_range*15/20  ) / num;
lum_portion_17   =  sum( logv >= lum_high-lum_range*17/20 & logv < lum_high-lum_range*16/20  ) / num;
lum_portion_18   =  sum( logv >= lum_high-lum_range*18/20 & logv < lum_high-lum_range*17/20  ) / num;
lum_portion_19   =  sum( logv >= lum_high-lum_range*19/20 & logv < lum_high-lum_range*18/20  ) / num;
lum_portion_20   =  sum(                                    logv < lum_high-lum_range*19/20  ) / num;




%% Harsh Lighting Features

unit = 0.25;   % by stop, in log domain
xx = [-10:unit:1];
cnts = hist(logv, xx);                % quantized histogram. each bin corresponds to one unit stop
cnts_thrsh = floor(sum(cnts) / 1000);
max_xx = max( xx(cnts>cnts_thrsh) );
cnts_high = cnts( xx<=max_xx & xx>=max_xx-3*unit);   % top bin ~  top - 3*unit bin

harshDrop     = max( max( diff(cnts_high) ./ cnts_high(2:end), 0) );      % 0 -1
highPortion   = sum( cnts_high(2:end) ) / sum(cnts);                    %

clear logv; clear num;


%%  Local Contrast

u = sort( I_lCntrst( Mask>=mask_thrsh & I_lCntrst>cntrst_thrsh), 'descend' );  % bg, local contrast map
u(isnan(u)) = [];   % remove NaN
num = length(u);
if num<100
    u = [u; ones(100-num, 1)*cntrst_thrsh ];
end

cntrst_top       = mean( u(1  :floor(1+top_ratio*num)) );
cntrst_low        = mean( u(floor(1+low_ratio*num):end) );
cntrst_median     = median( u );

% Other 1-order statistics of LOG histogram
cntrst_mean      = mean( u );
cntrst_std       = std( u );             
cntrst_skew      = skewness( u );   
cntrst_kurt      = kurtosis( u ) - 3;       % peakness

% entropy
u_norm = max(u, cntrst_thrsh);    %min u = cntrst_thrsh
u_norm = min(u_norm, 1);  %max u = 1.0
u_norm = (u_norm - cntrst_thrsh) / (1-cntrst_thrsh) * 255;  % scale u to 0~255
cntrst_entropy   = entropy( u_norm  );         % entropy() is originally for grayscale image, 0-255


% Range (Scale) of lCntrst Histogram
cntrst_range     =  cntrst_top - cntrst_low;                                   

% Shape (percentage) of lCntrst Histogram
cntrst_portion_01   =  sum( u >= cntrst_top-cntrst_range*1/20 ) / num;
cntrst_portion_02   =  sum( u >= cntrst_top-cntrst_range*2/20 & u < cntrst_top-cntrst_range*1/20  ) / num;
cntrst_portion_03   =  sum( u >= cntrst_top-cntrst_range*3/20 & u < cntrst_top-cntrst_range*2/20  ) / num;
cntrst_portion_04   =  sum( u >= cntrst_top-cntrst_range*4/20 & u < cntrst_top-cntrst_range*3/20  ) / num;
cntrst_portion_05   =  sum( u >= cntrst_top-cntrst_range*5/20 & u < cntrst_top-cntrst_range*4/20  ) / num;
cntrst_portion_06   =  sum( u >= cntrst_top-cntrst_range*6/20 & u < cntrst_top-cntrst_range*5/20  ) / num;
cntrst_portion_07   =  sum( u >= cntrst_top-cntrst_range*7/20 & u < cntrst_top-cntrst_range*6/20  ) / num;
cntrst_portion_08   =  sum( u >= cntrst_top-cntrst_range*8/20 & u < cntrst_top-cntrst_range*7/20  ) / num;
cntrst_portion_09   =  sum( u >= cntrst_top-cntrst_range*9/20 & u < cntrst_top-cntrst_range*8/20  ) / num;
cntrst_portion_10   =  sum( u >= cntrst_top-cntrst_range*10/20 & u < cntrst_top-cntrst_range*9/20  ) / num;
cntrst_portion_11   =  sum( u >= cntrst_top-cntrst_range*11/20 & u < cntrst_top-cntrst_range*10/20  ) / num;
cntrst_portion_12   =  sum( u >= cntrst_top-cntrst_range*12/20 & u < cntrst_top-cntrst_range*11/20  ) / num;
cntrst_portion_13   =  sum( u >= cntrst_top-cntrst_range*13/20 & u < cntrst_top-cntrst_range*12/20  ) / num;
cntrst_portion_14   =  sum( u >= cntrst_top-cntrst_range*14/20 & u < cntrst_top-cntrst_range*13/20  ) / num;
cntrst_portion_15   =  sum( u >= cntrst_top-cntrst_range*15/20 & u < cntrst_top-cntrst_range*14/20  ) / num;
cntrst_portion_16   =  sum( u >= cntrst_top-cntrst_range*16/20 & u < cntrst_top-cntrst_range*15/20  ) / num;
cntrst_portion_17   =  sum( u >= cntrst_top-cntrst_range*17/20 & u < cntrst_top-cntrst_range*16/20  ) / num;
cntrst_portion_18   =  sum( u >= cntrst_top-cntrst_range*18/20 & u < cntrst_top-cntrst_range*17/20  ) / num;
cntrst_portion_19   =  sum( u >= cntrst_top-cntrst_range*19/20 & u < cntrst_top-cntrst_range*18/20  ) / num;
cntrst_portion_20   =  sum(                                      u < cntrst_top-cntrst_range*19/20  ) / num;


clear u; clear num;


%% Color CCT

% CCT w.r.t different brightness
v = sort( I_bright( Mask>=mask_thrsh & I_bright<overExp_thrsh), 'descend');  % Remove Over-Exposured
v(isnan(v)) = [];
num = length(v);
b_thrsh_high        = v( floor(1+highlight_ratio*num) );  %bright threshold for bg (overExp removed)

cct_high = mean( I_cct (Mask>=mask_thrsh  & I_bright>=b_thrsh_high & I_bright<overExp_thrsh & ~isnan(I_cct))  );


% sorted CCT
vc = sort( I_cct(Mask>=mask_thrsh & I_bright>shdw_thrsh & I_bright<overExp_thrsh), 'descend' ); % bg, Remove Shadowed and overExp
vc(isnan(vc)) = [];     %remove NaN
num = length(vc);

% Basic
cct_warm      = mean( vc(1:floor(1+top_ratio*num)) );    % warmest 
cct_cold      = mean( vc(floor(1+low_ratio*num):end) );  % coldest
cct_median    = median( vc );                       % %50 quantile

% 1-order statistics of histogram
cct_mean      = mean( vc );
cct_std       = std( vc );             
cct_skew      = skewness( vc );   
cct_kurt      = kurtosis( vc ) - 3;       % peakness

% Entropy
minvc = 1e6/20000;
maxvc = 1e6/1500;
vc_norm = max(vc, minvc);    %min mired = max temp
vc_norm = min(vc_norm, maxvc);  %max mired = min temp
vc_norm = (vc_norm - minvc) / (maxvc-minvc) * 255;  % scale vc to 0~255
cct_entropy   = entropy( vc_norm  );         % entropy() is originally for grayscale image, 0-255


% Range (Scale) of histogram
cct_range     =  cct_warm - cct_cold;                                   

% Shape (percentage) of histogram
cct_portion_01   =  sum( vc >= cct_warm-cct_range*1/20 ) / num;
cct_portion_02   =  sum( vc >= cct_warm-cct_range*2/20 & vc < cct_warm-cct_range*1/20  ) / num;
cct_portion_03   =  sum( vc >= cct_warm-cct_range*3/20 & vc < cct_warm-cct_range*2/20  ) / num;
cct_portion_04   =  sum( vc >= cct_warm-cct_range*4/20 & vc < cct_warm-cct_range*3/20  ) / num;
cct_portion_05   =  sum( vc >= cct_warm-cct_range*5/20 & vc < cct_warm-cct_range*4/20  ) / num;
cct_portion_06   =  sum( vc >= cct_warm-cct_range*6/20 & vc < cct_warm-cct_range*5/20  ) / num;
cct_portion_07   =  sum( vc >= cct_warm-cct_range*7/20 & vc < cct_warm-cct_range*6/20  ) / num;
cct_portion_08   =  sum( vc >= cct_warm-cct_range*8/20 & vc < cct_warm-cct_range*7/20  ) / num;
cct_portion_09   =  sum( vc >= cct_warm-cct_range*9/20 & vc < cct_warm-cct_range*8/20  ) / num;
cct_portion_10   =  sum( vc >= cct_warm-cct_range*10/20 & vc < cct_warm-cct_range*9/20  ) / num;
cct_portion_11   =  sum( vc >= cct_warm-cct_range*11/20 & vc < cct_warm-cct_range*10/20  ) / num;
cct_portion_12   =  sum( vc >= cct_warm-cct_range*12/20 & vc < cct_warm-cct_range*11/20  ) / num;
cct_portion_13   =  sum( vc >= cct_warm-cct_range*13/20 & vc < cct_warm-cct_range*12/20  ) / num;
cct_portion_14   =  sum( vc >= cct_warm-cct_range*14/20 & vc < cct_warm-cct_range*13/20  ) / num;
cct_portion_15   =  sum( vc >= cct_warm-cct_range*15/20 & vc < cct_warm-cct_range*14/20  ) / num;
cct_portion_16   =  sum( vc >= cct_warm-cct_range*16/20 & vc < cct_warm-cct_range*15/20  ) / num;
cct_portion_17   =  sum( vc >= cct_warm-cct_range*17/20 & vc < cct_warm-cct_range*16/20  ) / num;
cct_portion_18   =  sum( vc >= cct_warm-cct_range*18/20 & vc < cct_warm-cct_range*17/20  ) / num;
cct_portion_19   =  sum( vc >= cct_warm-cct_range*19/20 & vc < cct_warm-cct_range*18/20  ) / num;
cct_portion_20   =  sum(                                  vc < cct_warm-cct_range*19/20  ) / num;



clear vc; clear num;




%% Color Saturation

I_S        = max(I_S, epsilon);       % prevent 0
% sorted Saturation
vs = sort( I_S(Mask>=mask_thrsh & I_bright>shdw_thrsh & I_bright<overExp_thrsh), 'descend' ); % bg, Remove Shadowed and OverExposed Saturation
logvs = log2(vs);         % logvs is more linear to HVS of saturation change (by multiply)
logvs(isnan(logvs)) = [];     %remove NaN
num = length(logvs);
clear vs;

% Basic
sat_top       = mean( logvs(1:floor(1+top_ratio*num)) );    
sat_low       = mean( logvs(floor(1+low_ratio*num):end) );  
sat_median    = median( logvs );                       % %50 quantile

% 1-order statistics of histogram
sat_mean      = mean( logvs );
sat_std       = std( logvs );             
sat_skew      = skewness( logvs );   
sat_kurt      = kurtosis( logvs ) - 3;       % peakness

% Entropy
logvs_norm = max(logvs, logeps);    
logvs_norm = min(logvs_norm, 0);  
logvs_norm = (logvs_norm - logeps) / (0-logeps) * 255;  % scale logvs to 0~255
sat_entropy   = entropy( logvs_norm  );         % entropy() is originally for grayscale image, 0-255


% Range (Scale) of histogram
sat_range     =  sat_top - sat_low;                                   

% Shape (percentage) of histogram
sat_portion_01   =  sum( logvs >= sat_top-sat_range*1/20 ) / num;
sat_portion_02   =  sum( logvs >= sat_top-sat_range*2/20 & logvs < sat_top-sat_range*1/20  ) / num;
sat_portion_03   =  sum( logvs >= sat_top-sat_range*3/20 & logvs < sat_top-sat_range*2/20  ) / num;
sat_portion_04   =  sum( logvs >= sat_top-sat_range*4/20 & logvs < sat_top-sat_range*3/20  ) / num;
sat_portion_05   =  sum( logvs >= sat_top-sat_range*5/20 & logvs < sat_top-sat_range*4/20  ) / num;
sat_portion_06   =  sum( logvs >= sat_top-sat_range*6/20 & logvs < sat_top-sat_range*5/20  ) / num;
sat_portion_07   =  sum( logvs >= sat_top-sat_range*7/20 & logvs < sat_top-sat_range*6/20  ) / num;
sat_portion_08   =  sum( logvs >= sat_top-sat_range*8/20 & logvs < sat_top-sat_range*7/20  ) / num;
sat_portion_09   =  sum( logvs >= sat_top-sat_range*9/20 & logvs < sat_top-sat_range*8/20  ) / num;
sat_portion_10   =  sum( logvs >= sat_top-sat_range*10/20 & logvs < sat_top-sat_range*9/20  ) / num;
sat_portion_11   =  sum( logvs >= sat_top-sat_range*11/20 & logvs < sat_top-sat_range*10/20  ) / num;
sat_portion_12   =  sum( logvs >= sat_top-sat_range*12/20 & logvs < sat_top-sat_range*11/20  ) / num;
sat_portion_13   =  sum( logvs >= sat_top-sat_range*13/20 & logvs < sat_top-sat_range*12/20  ) / num;
sat_portion_14   =  sum( logvs >= sat_top-sat_range*14/20 & logvs < sat_top-sat_range*13/20  ) / num;
sat_portion_15   =  sum( logvs >= sat_top-sat_range*15/20 & logvs < sat_top-sat_range*14/20  ) / num;
sat_portion_16   =  sum( logvs >= sat_top-sat_range*16/20 & logvs < sat_top-sat_range*15/20  ) / num;
sat_portion_17   =  sum( logvs >= sat_top-sat_range*17/20 & logvs < sat_top-sat_range*16/20  ) / num;
sat_portion_18   =  sum( logvs >= sat_top-sat_range*18/20 & logvs < sat_top-sat_range*17/20  ) / num;
sat_portion_19   =  sum( logvs >= sat_top-sat_range*19/20 & logvs < sat_top-sat_range*18/20  ) / num;
sat_portion_20   =  sum(                                 logvs < sat_top-sat_range*19/20  ) / num;



clear logvs; clear num;





%% Color HUE
hue_high = circ_mean( 2*pi*I_H (Mask>=mask_thrsh  & I_bright>=b_thrsh_high & I_bright<overExp_thrsh & ~isnan(I_H))  );
hue_high = hueRewind( hue_high/(2*pi) );

% sorted HUE (0~1)
vh = sort( I_H(Mask>=mask_thrsh & I_bright>shdw_thrsh & I_bright<overExp_thrsh), 'descend' ); % bg, Remove Shadowed and overexp
vh(isnan(vh)) = [];     %remove NaN
num = length(vh);

hue_median     = 0; %circ_median(2*pi*vh);
hue_median     = 0; %hueRewind( hue_median/(2*pi) );

% 1-order statistics of histogram
hue_mean     = circ_mean( 2*pi*vh );
hue_mean     = hueRewind( hue_mean/(2*pi) );

hue_std      = circ_std(2*pi*vh); % angular std = sqrt(2(1-R)), [0, sqrt(2)]  
hue_skew      = circ_skew( 2*pi*vh );           % skewness
hue_kurt      = circ_kurtosis( 2*pi*vh );       % peakness, >0 peaky

% Entropy
vh_norm = max(vh, 0);    
vh_norm = min(vh_norm, 1);  
vh_norm = (vh_norm - 0) / 1 * 255;  
hue_entropy   = entropy( vh_norm  );         % entropy() is originally for grayscale image, 0-255


% Range (Scale) of histogram,   aligned/centered by hue_mean
[erro, id] =  min( hueDist(vh, hue_mean) );

hue_range_50CW       =  hueDist( vh( mod(floor(id-0.5*num),num)+1 ), vh( mod(floor(id-0.3*num),num)+1 ) );     % rng cw -50  - 30% quantile
hue_range_30CW       =  hueDist( vh( mod(floor(id-0.3*num),num)+1 ), vh( mod(floor(id-0.1*num),num)+1 ) );     % rng cw -30  - 10% quantile
hue_range_center     =  hueDist( vh( mod(floor(id-0.1*num),num)+1 ), vh( mod(floor(id+0.1*num),num)+1 ) );     % rng center -10  - 10% quantile
hue_range_30CCW      =  hueDist( vh( mod(floor(id+0.1*num),num)+1 ), vh( mod(floor(id+0.3*num),num)+1 ) );     % rng ccw 10  - 30% quantile
hue_range_50CCW      =  hueDist( vh( mod(floor(id+0.3*num),num)+1 ), vh( mod(floor(id+0.5*num),num)+1 ) );     % rng ccw 30  - 50% quantile


% Shape (percentage) of histogram,   aligned/centered by hue_mean
hue_portion_10CW     =  sum( findHueInterval(vh, hueRewind(hue_mean+9/20), hueRewind(hue_mean+10/20)) ) / num;  
hue_portion_09CW     =  sum( findHueInterval(vh, hueRewind(hue_mean+8/20), hueRewind(hue_mean+9/20)) ) / num;  
hue_portion_08CW     =  sum( findHueInterval(vh, hueRewind(hue_mean+7/20), hueRewind(hue_mean+8/20)) ) / num;  
hue_portion_07CW     =  sum( findHueInterval(vh, hueRewind(hue_mean+6/20), hueRewind(hue_mean+7/20)) ) / num;  
hue_portion_06CW     =  sum( findHueInterval(vh, hueRewind(hue_mean+5/20), hueRewind(hue_mean+6/20)) ) / num;  
hue_portion_05CW     =  sum( findHueInterval(vh, hueRewind(hue_mean+4/20), hueRewind(hue_mean+5/20)) ) / num;  
hue_portion_04CW     =  sum( findHueInterval(vh, hueRewind(hue_mean+3/20), hueRewind(hue_mean+4/20)) ) / num;   
hue_portion_03CW     =  sum( findHueInterval(vh, hueRewind(hue_mean+2/20), hueRewind(hue_mean+3/20)) ) / num;  
hue_portion_02CW     =  sum( findHueInterval(vh, hueRewind(hue_mean+1/20), hueRewind(hue_mean+2/20)) ) / num;  
hue_portion_01CW     =  sum( findHueInterval(vh, hueRewind(hue_mean), hueRewind(hue_mean+1/20)) ) / num;     % clock wise, degree (hue) increase
hue_portion_01CCW    =  sum( findHueInterval(vh, hueRewind(hue_mean-1/20), hueRewind(hue_mean)) ) / num;     % counter-clock wise, degree (hue) decrease
hue_portion_02CCW    =  sum( findHueInterval(vh, hueRewind(hue_mean-2/20), hueRewind(hue_mean-1/20)) ) / num;
hue_portion_03CCW    =  sum( findHueInterval(vh, hueRewind(hue_mean-3/20), hueRewind(hue_mean-2/20)) ) / num;
hue_portion_04CCW    =  sum( findHueInterval(vh, hueRewind(hue_mean-4/20), hueRewind(hue_mean-3/20)) ) / num;
hue_portion_05CCW    =  sum( findHueInterval(vh, hueRewind(hue_mean-5/20), hueRewind(hue_mean-4/20)) ) / num;
hue_portion_06CCW    =  sum( findHueInterval(vh, hueRewind(hue_mean-6/20), hueRewind(hue_mean-5/20)) ) / num;
hue_portion_07CCW    =  sum( findHueInterval(vh, hueRewind(hue_mean-7/20), hueRewind(hue_mean-6/20)) ) / num;
hue_portion_08CCW    =  sum( findHueInterval(vh, hueRewind(hue_mean-8/20), hueRewind(hue_mean-7/20)) ) / num;
hue_portion_09CCW    =  sum( findHueInterval(vh, hueRewind(hue_mean-9/20), hueRewind(hue_mean-8/20)) ) / num;
hue_portion_10CCW    =  sum( findHueInterval(vh, hueRewind(hue_mean-10/20), hueRewind(hue_mean-9/20)) ) / num;

clear vh; clear num;


           
            
%% %% %% %% OUTPUT %% %% %% %% 

features = [    ... % Luminance
    lum_high, lum_shdw, lum_median, ...   %+3  =3
    lum_mean, lum_std,  lum_skew, lum_kurt, lum_entropy, lum_range, ...              %+6    9
    lum_portion_01,lum_portion_02,lum_portion_03,lum_portion_04,lum_portion_05,  ...
    lum_portion_06,lum_portion_07,lum_portion_08,lum_portion_09,lum_portion_10,  ...
    lum_portion_11,lum_portion_12,lum_portion_13,lum_portion_14,lum_portion_15,  ...
    lum_portion_16,lum_portion_17,lum_portion_18,lum_portion_19,lum_portion_20,   ...     %+20   29
                ... % harsh Lighting
    harshDrop, highPortion, ...     %+2   31
                ... % Local Contrast
    cntrst_top, cntrst_low, cntrst_median, ...    %+3   34
    cntrst_mean, cntrst_std, cntrst_skew, cntrst_kurt, cntrst_entropy, cntrst_range, ... %+6     40
    cntrst_portion_01,cntrst_portion_02,cntrst_portion_03,cntrst_portion_04,cntrst_portion_05,  ...
    cntrst_portion_06,cntrst_portion_07,cntrst_portion_08,cntrst_portion_09,cntrst_portion_10,  ...
    cntrst_portion_11,cntrst_portion_12,cntrst_portion_13,cntrst_portion_14,cntrst_portion_15,  ...
    cntrst_portion_16,cntrst_portion_17,cntrst_portion_18,cntrst_portion_19,cntrst_portion_20,   ... %+20    60
                ...% Color CCT
    cct_high, cct_warm, cct_cold, cct_median,   ... %+4   64
    cct_mean, cct_std, cct_skew, cct_kurt, cct_entropy,  cct_range, ...    %+6     70
    cct_portion_01,cct_portion_02,cct_portion_03,cct_portion_04,cct_portion_05,  ...
    cct_portion_06,cct_portion_07,cct_portion_08,cct_portion_09,cct_portion_10,  ...
    cct_portion_11,cct_portion_12,cct_portion_13,cct_portion_14,cct_portion_15,  ...
    cct_portion_16,cct_portion_17,cct_portion_18,cct_portion_19,cct_portion_20,   ...    %+20     90
                ...% Color Saturation
    sat_top, sat_low, sat_median,  ...      %+3     93
    sat_mean, sat_std, sat_skew, sat_kurt, sat_entropy, sat_range,  ...   %+6     99
    sat_portion_01,sat_portion_02,sat_portion_03,sat_portion_04,sat_portion_05,  ...
    sat_portion_06,sat_portion_07,sat_portion_08,sat_portion_09,sat_portion_10,  ...
    sat_portion_11,sat_portion_12,sat_portion_13,sat_portion_14,sat_portion_15,  ...
    sat_portion_16,sat_portion_17,sat_portion_18,sat_portion_19,sat_portion_20,   ... %+20    119
                ...% Color HUE
    hue_high, hue_median, ...   % +2    121
    hue_mean, hue_std, hue_skew, hue_kurt, hue_entropy, ...        %+5     126
    hue_range_50CW,hue_range_30CW,hue_range_center,hue_range_30CCW,hue_range_50CCW, ...    %+5    131
    hue_portion_10CW,hue_portion_09CW,hue_portion_08CW,hue_portion_07CW,hue_portion_06CW,  ...
    hue_portion_05CW,hue_portion_04CW,hue_portion_03CW,hue_portion_02CW,hue_portion_01CW,  ...
    hue_portion_01CCW,hue_portion_02CCW,hue_portion_03CCW,hue_portion_04CCW,hue_portion_05CCW,  ...
    hue_portion_06CCW,hue_portion_07CCW,hue_portion_08CCW,hue_portion_09CCW,hue_portion_10CCW,   ... %+20  151
];
function outI = manipulateFeature(goal, I, Mask, shift_f, shift_b)
%INPUT: I: 3channel, 0~1
%INPUT: Mask, 1 channel, 0~1

%% Parameters
mask_thrsh = 0.5;

% 1-GammaInv(245/255) = 0.0869; 1-GammaInv(118/255)/GammaInv(128/255) = 0.1607
cntrst_thrsh = 0.10;  % lowest cntrst we consider

top_ratio  = 1/1024; %robust highest end. in Photoshop, by default 0.1%
low_ratio  = 1-top_ratio;  %robust lowest end.
highlight_ratio = 1/128;   % for cct and hue


%%
I_GammaInv = GammaInv(I); %imadjust(I, [0 0 0;1 1 1], [0 0 0;1 1 1], 2.2); % inverse Gamma (LDR->HDR)
I_ready = I_GammaInv;
%figure; imshow(I_ready);
clear I_GammaInv;

switch goal
    case 'lum'
        I_XYZ   =  rgb2xyz(I_ready, 'srgb', 'D65/2', 'Gamma', 1);  %0~100
        I_xyY    =  xyz2xyy(I_XYZ);
        
        I_bright   = I_xyY(:,:,3)/100;   % 0~1
        I_bright(Mask>mask_thrsh)   = I_bright(Mask>mask_thrsh) .* (2^shift_f);   % forground
        I_bright(Mask<=mask_thrsh)  = I_bright(Mask<=mask_thrsh) .* (2^shift_b);   % backround
        
        I_xyY(:,:,3) = I_bright*100;  % 0~100

        I_XYZ   =  xyy2xyz(I_xyY);  %out: 0~100
        outI    =  xyz2rgb(I_XYZ, 'D65/2', 'srgb', 'Gamma', 1);  %0~100
        
    case 'cntrst'
        % Original cntrst
        I_XYZ   =  rgb2xyz(I_ready, 'srgb', 'D65/2', 'Gamma', 1);  %0~100
        I_xyY    =  xyz2xyy(I_XYZ);
        I_bright   = I_xyY(:,:,3) / 100;  
        
        I_lCntrst   = calcLocalCntrst_Bright(I_bright);

        uf = sort( I_lCntrst( Mask>=mask_thrsh & I_lCntrst>cntrst_thrsh), 'descend' );  % fg, local contrast map
        uf(isnan(uf))=[];
        num = length(uf);
        if num<100, uf = [uf; ones(100-num, 1)*cntrst_thrsh ]; end
        lCntrst_largest_F   = mean( uf(1  :floor(1+top_ratio*num)) );
        lCntrst_least_F     = mean( uf(floor(1+low_ratio*num):end) );
        lCntrst_mean_F      = mean( uf );
        
%         ub = sort( I_lCntrst( Mask<mask_thrsh & I_lCntrst>cntrst_thrsh), 'descend' );  % bg, local contrast map
%         ub(isnan(ub))=[];
%         num = length(ub);
%         if num<100, ub = [ub; ones(100-num, 1)*cntrst_thrsh ]; end
%         lCntrst_largest_B   = mean( ub(1  :floor(1+top_ratio*num)) );
%         lCntrst_least_B     = mean( ub(floor(1+low_ratio*num):end) );
%         lCntrst_mean_B      = mean( ub );

        minError_F = 1000;   alpBest_F = 0.5;   diffBest_F = 0.0;
%        minError_B = 1000;   alpBest_B = 0.5;   diffBest_B = 0.0;

        thrsh_F = mean( I_bright(Mask>mask_thrsh) );   
        for alp = 0.4:0.05:0.6    % 0.5 unchanged [0.4~0.6] is default
            F_bright_adj = AdjustLocCntrst(I_bright, thrsh_F, alp);    % Adjust according to Fg thrsh
            
            F_lCntrst_adj   = calcLocalCntrst_Bright(F_bright_adj);

            uf = sort( F_lCntrst_adj( Mask>=mask_thrsh & F_lCntrst_adj>cntrst_thrsh), 'descend' );  % fg, local contrast map
            uf(isnan(uf)) = [];   % remove NaN
            num = length(uf);
            if num<100
                uf = [uf; ones(100-num, 1)*cntrst_thrsh ];
            end
            lCntrst_largest_adj_F   = mean( uf(1  :floor(1+top_ratio*num)) );
            lCntrst_least_adj_F     = mean( uf(floor(1+low_ratio*num):end) );
            lCntrst_mean_adj_F     = mean( uf );

%             ub = sort( I_lCntrst_adj( Mask<mask_thrsh & I_lCntrst_adj>cntrst_thrsh), 'descend' );  % bg, local contrast map
%             ub(isnan(ub)) = [];   % remove NaN
%             num = length(ub);
%             if num<100
%                 ub = [ub; ones(100-num, 1)*cntrst_thrsh ];
%             end
%             lCntrst_largest_adj_B   = mean( ub(1  :floor(1+top_ratio*num)) );
%             lCntrst_least_adj_B     = mean( ub(floor(1+low_ratio*num):end) );
%             lCntrst_mean_adj_B      = mean( ub );
        
            % use Top cntrst to generate manipulated composites
            diff_F = lCntrst_largest_adj_F - lCntrst_largest_F;
            error_F = abs(diff_F - shift_f);

%             diff_B = lCntrst_largest_adj_B - lCntrst_largest_B;
%             error_B = abs(diff_B - shift_b);
            
            disp( sprintf('alp = %f, diff_F=%f', alp, diff_F) );
            %disp( sprintf('alp = %f, diff_F=%f, diff_B=%f', alp, diff_F, diff_B) );
            
            if  error_F < minError_F
                % Adjust foreground
                minError_F    = error_F;
                alpBest_F   = alp;
                diffBest_F    = diff_F;
            end
            
%             if  error_B < minError_B
%                 % Adjust background
%                 minError_B    = error_B;
%                 alpBest_B   = alp;
%                 diffBest_B    = diff_B;
%             end

        end % alp
        disp( sprintf('alpBest_F=%f, diffBest_F=%f', alpBest_F, diffBest_F) );
        %disp( sprintf('alpBest_F=%f, alpBest_B=%f, diffBest_F=%f, diffBest_B=%f', alpBest_F, alpBest_B, diffBest_F, diffBest_B) );
       
        bright_F_adj = AdjustLocCntrst(I_bright, thrsh_F, alpBest_F);  
        %bright_B_adj = AdjustLocCntrst(bright_B, alpBest_B);  

        I_bright(Mask>mask_thrsh) = bright_F_adj(Mask>mask_thrsh);
       
        I_xyY(:,:,3) = I_bright * 100;

        I_XYZ   =  xyy2xyz(I_xyY);  %out: 0~100
        outI    =  xyz2rgb(I_XYZ, 'D65/2', 'srgb', 'Gamma', 1);  %0~100
        
    case 'cct'
        I_XYZ    =  rgb2xyz(I_ready, 'srgb', 'D65/2', 'Gamma', 1.0);
        I_xyY    =  xyz2xyy(I_XYZ);
        I_xy     = I_xyY(:,:, 1:2);
        
        ht = size(I_xy,1);
        wid = size(I_xy,2);
        I_cct = zeros(ht,wid);
        I_tint = zeros(ht,wid);
        for i = 1:ht
            for j = 1:wid
                [mired, tint] = CalcMiredAndTint_byxy(I_xy(i,j,1), I_xy(i,j,2));
                I_cct(i,j)  = mired;
                I_tint(i,j) = tint;
            end
        end
        
        I_cct(Mask>mask_thrsh)  = I_cct(Mask>mask_thrsh) + shift_f;
        I_cct(Mask<=mask_thrsh) = I_cct(Mask<=mask_thrsh) + shift_b;
        
        for i = 1:ht
            for j = 1:wid
                mired = I_cct(i,j);  tint = I_tint(i,j);
                [x, y] = Calcxy_byMiredAndTint(mired,tint);
                I_xy(i,j, 1)  = x;
                I_xy(i,j, 2)  = y;
            end
        end
        
        if shift_b == 0    % Don't touch background
          I_x = I_xyY(:,:,1);   I_y = I_xyY(:,:,2);
          I_xNew = I_xy(:,:,1); I_yNew = I_xy(:,:,2);
          I_x(Mask>mask_thrsh) = I_xNew(Mask>mask_thrsh);
          I_y(Mask>mask_thrsh) = I_yNew(Mask>mask_thrsh);
          I_xy(:,:,1) = I_x;
          I_xy(:,:,2) = I_y;
        end
        
        I_xyY(:,:,1:2) = I_xy;
        
        
        I_XYZ   =  xyy2xyz(I_xyY);  %out: 0~100
        outI    =  xyz2rgb(I_XYZ, 'D65/2', 'srgb', 'Gamma', 1);  %0~100
        
    case 'sat'
        [I_H, I_S, I_V]  = rgb2hsv(I_ready);  % H, S, V, 0-1. H is periodic in [0,1]
        I_S(Mask>mask_thrsh)   = I_S(Mask>mask_thrsh) .* (2^shift_f);    % forground
        I_S(Mask<=mask_thrsh)  = I_S(Mask<=mask_thrsh) .* (2^shift_b);   % backround
        outI  = hsv2rgb( I_H, I_S, I_V );
    case 'hue'
        [I_H, I_S, I_V]  = rgb2hsv(I_ready);  % H, S, V, 0-1. H is periodic in [0,1]
        I_H(Mask>mask_thrsh)   = hueRewind(I_H(Mask>mask_thrsh) + shift_f);    % forground
        I_H(Mask<=mask_thrsh)  = hueRewind(I_H(Mask<=mask_thrsh) + shift_b);   % backround
        outI  = hsv2rgb( I_H, I_S, I_V );
end


%% Output: ready to display
% Fill NaN (clip some underflowing pixels)
outI_r = outI(:,:,1);
outI_r(isnan(outI_r)) = 0; %mean(mean(outI_r(~isnan(outI_r))));

outI_g = outI(:,:,2);
outI_g(isnan(outI_g)) = 0; %mean(mean(outI_g(~isnan(outI_g))));

outI_b = outI(:,:,3);
outI_b(isnan(outI_b)) = 0; %mean(mean(outI_b(~isnan(outI_b))));

outI(:,:,1) = outI_r;
outI(:,:,2) = outI_g;
outI(:,:,3) = outI_b;

outI = GammaFwd( outI ); %imadjust(outI, [0 0 0;1 1 1], [0 0 0;1 1 1], 1/2.2); % alp (HDR->LDR) for display


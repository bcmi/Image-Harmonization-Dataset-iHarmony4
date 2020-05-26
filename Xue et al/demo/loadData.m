index = 1;
for i = 1:nComp
    fgbgFeatures = cell_compositing_all{i}{1};
   
    assignFeatures;

    
    %% Feature for learning offset
    switch goal
        case 'lum'
        Features_Off =  [   ...   % Foreground      Remove portion_18 for fixing rank-deficiency   Remove Range
                        lum_std_F,  lum_skew_F, lum_kurt_F, lum_entropy_F, ...              
                        lum_portion_01_F,lum_portion_02_F,lum_portion_03_F,lum_portion_04_F,lum_portion_05_F,  ...
                        lum_portion_06_F,lum_portion_07_F,lum_portion_08_F,lum_portion_09_F,lum_portion_10_F,  ...
                        lum_portion_11_F,lum_portion_12_F,lum_portion_13_F,lum_portion_14_F,lum_portion_15_F,  ...
                        lum_portion_16_F,lum_portion_17_F,                 lum_portion_19_F,lum_portion_20_F,   ...     
                           ...   % Background
                         lum_std_B, lum_skew_B, lum_kurt_B, lum_entropy_B, ...              
                         lum_portion_01_B,lum_portion_02_B,lum_portion_03_B,lum_portion_04_B,lum_portion_05_B,  ...
                         lum_portion_06_B,lum_portion_07_B,lum_portion_08_B,lum_portion_09_B,lum_portion_10_B,  ...
                         lum_portion_11_B,lum_portion_12_B,lum_portion_13_B,lum_portion_14_B,lum_portion_15_B,  ...
                         lum_portion_16_B,lum_portion_17_B,               lum_portion_19_B,lum_portion_20_B,   ...     
                        ];
        case 'cntrst'
        Features_Off = [    ... % Foreground    % Remove cntrst_range that is equal to cntrst_top
                        cntrst_std_F, cntrst_skew_F, cntrst_kurt_F, cntrst_entropy_F, ... %
                        cntrst_portion_01_F,cntrst_portion_02_F,cntrst_portion_03_F,cntrst_portion_04_F,cntrst_portion_05_F,  ...
                        cntrst_portion_06_F,cntrst_portion_07_F,cntrst_portion_08_F,cntrst_portion_09_F,cntrst_portion_10_F,  ...
                        cntrst_portion_11_F,cntrst_portion_12_F,cntrst_portion_13_F,cntrst_portion_14_F,cntrst_portion_15_F,  ...
                        cntrst_portion_16_F,cntrst_portion_17_F,                    cntrst_portion_19_F,cntrst_portion_20_F,   ... %
                            ... % background
                        cntrst_std_B, cntrst_skew_B, cntrst_kurt_B, cntrst_entropy_B, ... %
                        cntrst_portion_01_B,cntrst_portion_02_B,cntrst_portion_03_B,cntrst_portion_04_B,cntrst_portion_05_B,  ...
                        cntrst_portion_06_B,cntrst_portion_07_B,cntrst_portion_08_B,cntrst_portion_09_B,cntrst_portion_10_B,  ...
                        cntrst_portion_11_B,cntrst_portion_12_B,cntrst_portion_13_B,cntrst_portion_14_B,cntrst_portion_15_B,  ...
                        cntrst_portion_16_B,cntrst_portion_17_B,                    cntrst_portion_19_B,cntrst_portion_20_B,   ... %
                       ];
        case 'cct'
        Features_Off = [
                        ...% Color CCT
                        cct_std_F, cct_skew_F, cct_kurt_F, cct_entropy_F,   ...    %+6     
                        cct_portion_01_F,cct_portion_02_F,cct_portion_03_F,cct_portion_04_F,cct_portion_05_F,  ...
                        cct_portion_06_F,cct_portion_07_F,cct_portion_08_F,cct_portion_09_F,cct_portion_10_F,  ...
                        cct_portion_11_F,cct_portion_12_F,cct_portion_13_F,cct_portion_14_F,cct_portion_15_F,  ...
                        cct_portion_16_F,cct_portion_17_F,                 cct_portion_19_F,cct_portion_20_F,   ...    %+20     
                                ...% Color CCT
                        cct_std_B, cct_skew_B, cct_kurt_B, cct_entropy_B, ...    %+6     
                        cct_portion_01_B,cct_portion_02_B,cct_portion_03_B,cct_portion_04_B,cct_portion_05_B,  ...
                        cct_portion_06_B,cct_portion_07_B,cct_portion_08_B,cct_portion_09_B,cct_portion_10_B,  ...
                        cct_portion_11_B,cct_portion_12_B,cct_portion_13_B,cct_portion_14_B,cct_portion_15_B,  ...
                        cct_portion_16_B,cct_portion_17_B,                 cct_portion_19_B,cct_portion_20_B,   ...    %+20     
                       ];
        case 'sat'
        Features_Off =  [   ...   % Foreground      Remove portion_18 for fixing rank-deficiency
                        sat_std_F, sat_skew_F, sat_kurt_F, sat_entropy_F,  ...   %+6     
                        sat_portion_01_F,sat_portion_02_F,sat_portion_03_F,sat_portion_04_F,sat_portion_05_F,  ...
                        sat_portion_06_F,sat_portion_07_F,sat_portion_08_F,sat_portion_09_F,sat_portion_10_F,  ...
                        sat_portion_11_F,sat_portion_12_F,sat_portion_13_F,sat_portion_14_F,sat_portion_15_F,  ...
                        sat_portion_16_F,sat_portion_17_F,               sat_portion_19_F,sat_portion_20_F,   ... %+20    
                            ...   % Background
                         sat_std_B, sat_skew_B, sat_kurt_B, sat_entropy_B, ...   %+6     
                        sat_portion_01_B,sat_portion_02_B,sat_portion_03_B,sat_portion_04_B,sat_portion_05_B,  ...
                        sat_portion_06_B,sat_portion_07_B,sat_portion_08_B,sat_portion_09_B,sat_portion_10_B,  ...
                        sat_portion_11_B,sat_portion_12_B,sat_portion_13_B,sat_portion_14_B,sat_portion_15_B,  ...
                        sat_portion_16_B,sat_portion_17_B,                 sat_portion_19_B,sat_portion_20_B,   ... %+20    
                        ];
        case 'hue'
        Features_Off =  [   ...   % Foreground
                        hue_std_F, hue_entropy_F, ...        %+4   Remove one portion to fix rank-deficiency
                        hue_portion_10CW_F,hue_portion_09CW_F,hue_portion_08CW_F,hue_portion_07CW_F,hue_portion_06CW_F,  ...
                        hue_portion_05CW_F,hue_portion_04CW_F,hue_portion_03CW_F,hue_portion_02CW_F,hue_portion_01CW_F,  ...
                        hue_portion_01CCW_F,hue_portion_02CCW_F,hue_portion_03CCW_F,hue_portion_04CCW_F,hue_portion_05CCW_F,  ...
                        hue_portion_06CCW_F,hue_portion_07CCW_F,                    hue_portion_09CCW_F,hue_portion_10CCW_F,   ... %+20  
                            ...  % Background
                        hue_std_B, hue_entropy_B, ...        %+4   
                        hue_portion_10CW_B,hue_portion_09CW_B,hue_portion_08CW_B,hue_portion_07CW_B,hue_portion_06CW_B,  ...
                        hue_portion_05CW_B,hue_portion_04CW_B,hue_portion_03CW_B,hue_portion_02CW_B,hue_portion_01CW_B,  ...
                        hue_portion_01CCW_B,hue_portion_02CCW_B,hue_portion_03CCW_B,hue_portion_04CCW_B,hue_portion_05CCW_B,  ...
                        hue_portion_06CCW_B,hue_portion_07CCW_B,                    hue_portion_09CCW_B,hue_portion_10CCW_B,   ... %+20  
                        ];
    end; % if
    
    %% Real Offset
    switch goal
        case 'lum'
            switch lower(region)
                case 'top'
                    offset = lum_high_F - lum_high_B;  
                case 'low'
                    offset = lum_shdw_F - lum_shdw_B;
                case 'mean'
                    offset = lum_mean_F - lum_mean_B;          
            end
        case 'cntrst'
            switch lower(region)
                case 'top'
                    offset = cntrst_top_F - cntrst_top_B;  
                case 'low'
                    offset = cntrst_low_F - cntrst_low_B;
                case 'mean'
                    offset = cntrst_mean_F - cntrst_mean_B;          
            end
        case 'cct'
            switch lower(region)
                case 'top'
                    offset = cct_warm_F - cct_warm_B;  
                case 'low'
                    offset = cct_cold_F - cct_cold_B;
                case 'mean'
                    offset = cct_mean_F - cct_mean_B;          
                case 'high'
                    offset = cct_high_F - cct_high_B;          
            end
        case 'sat'
             switch lower(region)
                case 'top'
                    offset = sat_top_F - sat_top_B;  
                case 'low'
                    offset = sat_low_F - sat_low_B;
                case 'mean'
                    offset = sat_mean_F - sat_mean_B;          
            end
        case 'hue'
             switch lower(region)
                case 'high'
                    offset = hue_high_F-hue_high_B;  
                case 'mean'
                    offset = hue_mean_F-hue_mean_B;  
             end
             if offset>0.5
                offset = offset -1;
             elseif offset<-0.5
                offset = offset + 1;
             end;
    end
    
    if  sum( isnan([Features_Off, offset])) > 0
        disp(sprintf('Warning: there is NaN in Features_Off or offset.'));
        continue;
    end

    
    X(index, :) = Features_Off;
    p(index, :) = offset;
    if  ~isempty( strfind(goal, 'hue') ) %goal for hue
        p_c(index, :) = cos(p(index)*2*pi);
        p_s(index, :) = sin(p(index)*2*pi);
    end
    
    index = index + 1;
end
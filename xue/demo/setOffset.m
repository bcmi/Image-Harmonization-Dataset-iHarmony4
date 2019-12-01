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
         if offset>0.5,
             offset = offset -1;
         elseif offset<-0.5
             offset = offset + 1;
         end;
end
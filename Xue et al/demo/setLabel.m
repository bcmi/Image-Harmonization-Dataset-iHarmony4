switch goal
    case 'lum',
            d1(index, :) = lum_high_F - lum_high_B;  
            d2(index, :) = lum_shdw_F - lum_shdw_B;
            d3(index, :) = lum_mean_F - lum_mean_B;
            d4 = [];
            a = [d1(index), d2(index), d3(index)];  
    case 'cntrst',
            d1(index, :) = cntrst_top_F  - cntrst_top_B;  
            d2(index, :) = cntrst_mean_F - cntrst_mean_B;    
            d3 = [];
            d4 = [];
            a = [d1(index), d2(index)];  
    case 'cct',
            d1(index, :) = cct_warm_F - cct_warm_B;  
            d2(index, :) = cct_cold_F - cct_cold_B;   
            d3(index, :) = cct_mean_F - cct_mean_B;    
            d4(index, :) = cct_high_F - cct_high_B;
            a = [d1(index), d2(index), d3(index), d4(index)];  
    case 'sat',
            d1(index, :) = sat_top_F - sat_top_B;
            d2(index, :) = sat_low_F - sat_low_B;
            d3(index, :) = sat_mean_F - sat_mean_B;    
            d4 = [];
            a = [d1(index), d2(index), d3(index)];  
    case 'hue',
            d1(index, :) = hue_high_F - hue_high_B;  
            if d1(index)>0.5
                d1(index) = d1(index) -1;
            elseif d1(index)<-0.5
                d1(index) = d1(index) + 1;
            end;
            d2(index, :) = hue_mean_F - hue_mean_B; 
            if d2(index)>0.5
                d2(index) = d2(index) -1;
            elseif d2(index)<-0.5
                d2(index) = d2(index) + 1;
            end;
            d3 = [];
            d4 = [];
            a = [d1(index), d2(index)];  
end


[c, ii] = min( abs(a) );
d(index, :)     = a(ii);         % Min-offset

label = ii;       
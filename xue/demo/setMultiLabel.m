%% % output: label_1, label_2, label_3, label_4

%% Set tolerance

switch goal
    case 'lum',
        tol_top  = 3.19 * ss;
        tol_low  = 3.19 * ss;
        tol_mean = 3.19 * ss;
%         tol_top   = 2.500196 * ss;
%         tol_low   =  3.138705  * ss;
%         tol_mean = 3.344171 * ss;
    case 'cct',
        tol_top  = 65.18 * ss;
        tol_low  = 65.18 * ss;
        tol_mean = 65.18 * ss;
        %tol_high = 112.641927 * ss;
%         tol_top  = 83.252058 * ss;
%         tol_low  = 105.318797 * ss;
%         tol_mean = 94.340061 * ss;

    case 'sat',
        tol_top  = 0.993 * ss;
        tol_low  = 0.993 * ss;
        tol_mean = 0.993 * ss;
        %tol_high = 112.641927 * ss;
end

%% Set label
switch goal
    case 'lum',
            d1(index, :) = lum_high_F - lum_high_B;  
            d2(index, :) = lum_shdw_F - lum_shdw_B;
            d3(index, :) = lum_mean_F - lum_mean_B;
            d4 = [];
            label_1 = (abs(d1(index))<tol_top);
            label_2 = (abs(d2(index))<tol_low);
            label_3 = (abs(d3(index))<tol_mean);
            label_4 = [];
            a = [d1(index), d2(index), d3(index)];  
    case 'cntrst',
            d1(index, :) = cntrst_top_F  - cntrst_top_B;  
            d2(index, :) = cntrst_mean_F - cntrst_mean_B;    
            d3 = [];
            d4 = [];
            label_1 = (abs(d1(index))<tol_top);
            label_2 = (abs(d2(index))<tol_mean);
            label_3 = [];
            label_4 = [];
            a = [d1(index), d2(index)];  
    case 'cct',
            d1(index, :) = cct_warm_F - cct_warm_B;  
            d2(index, :) = cct_cold_F - cct_cold_B;   
            d3(index, :) = cct_mean_F - cct_mean_B;    
            %d4(index, :) = cct_high_F - cct_high_B;
            d4   = [];
            label_1 = (abs(d1(index))<tol_top);
            label_2 = (abs(d2(index))<tol_low);
            label_3 = (abs(d3(index))<tol_mean);
            %label_4 = (abs(d3(index))<tol_high);
            label_4 = [];
            %a = [d1(index), d2(index), d3(index), d4(index)];  
            a = [d1(index), d2(index), d3(index)];
    case 'sat',
            d1(index, :) = sat_top_F - sat_top_B;
            d2(index, :) = sat_low_F - sat_low_B;
            d3(index, :) = sat_mean_F - sat_mean_B;    
            d4 = [];
            label_1 = (abs(d1(index))<tol_top);
            label_2 = (abs(d2(index))<tol_low);
            label_3 = (abs(d3(index))<tol_mean);
            label_4 = [];
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
            label_1 = (abs(d1(index))<tol_high);
            label_2 = (abs(d2(index))<tol_mean);
            label_3 = [];
            label_4 = [];
            a = [d1(index), d2(index)];  
end

% Logical to double
label_1 = double(label_1);
label_2 = double(label_2);
label_3 = double(label_3);
label_4 = double(label_4);

% Min Offset
[c, ii] = min( abs(a) );
d(index, :)     = a(ii);         % Min-offset

label = ii;  %label of min Offset  (Not used here) 
switch ii    % the min-Offset label is always 1,  for training
    case 1,  label_1 = 1;
    case 2,  label_2 = 1;
    case 3,  label_3 = 1;
    case 4,  label_4 = 1;
end


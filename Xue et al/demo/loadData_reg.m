index = 1;
for i = 1:nComp
    fgbgFeatures = cell_compositing_all{i}{1};
   
    assignFeatures;

    
    %% Feature for learning offset
    selectFeatures;  % Output: Feature_Off
    
    
    %% Real Offset
    setOffset;  % Output: offset
        
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
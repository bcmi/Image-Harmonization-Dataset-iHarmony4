index = 1;
for i = 1:nComp
    fgbgFeatures = cell_compositing_all{i}{1};
   
    assignFeatures;

    
    %% Features for learning labels
    selectFeatures;  %output: Features_Off
    
    
    %%  Real the Min-offsets and Labels
    setMultiLabel;  % output: label_1, label_2, label_3, label_4

    if  sum( isnan([Features_Off, label'])) > 0
        disp(sprintf('Warning: there is NaN in Features_Off or label.'));
        continue;
    end
    
    
    %% Set the predictors and variables
    X(index, :) =   Features_Off;
    p(index, :) =   label;
    
    if ~isempty(label_1), 
        p1(index, :) = label_1; 
    else
        p1 = [];
    end
    
    if ~isempty(label_2),
        p2(index, :) = label_2; 
    else
        p2 = [];
    end
    
    if ~isempty(label_3),
        p3(index, :) = label_3; 
    else
        p3 = [];
    end
    
    if ~isempty(label_4), 
        p4(index, :) = label_4; 
    else
        p4 = [];
    end
    
    %% iteration continues
    index = index + 1;
end

index = 1;
for i = 1:nComp
    fgbgFeatures = cell_compositing_all{i}{1};
   
    assignFeatures;

    
    %% Features for learning labels
    selectFeatures;  %output: Features_Off
    
    
    %%  Real the Min-offsets and Labels
    setLabel;  % output: label     
    
    if  sum( isnan([Features_Off, label'])) > 0
        disp(sprintf('Warning: there is NaN in Features_Off or label.'));
        continue;
    end
    
    
    %% Set the predictors and variables
    X(index, :) =   Features_Off;
    p(index, :) =   label;
    
    
    %% iteration continues
    index = index + 1;
end

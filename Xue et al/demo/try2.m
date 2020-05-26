%% compare the foreground and background histograms

close all; clc; 
clear all;

load ('data\\cell_compositing_all.mat');   % load cell_compositing_all

nComp = length(cell_compositing_all);

goal = 'lum';   % 'lum', 'cntrst', 'cct', 'sat', 'hue'

disp(sprintf('Class RF. Goal = %s', goal));

index = 1;
for i = 1:nComp
    clc;
    fgbgFeatures = cell_compositing_all{i}{1};
   
    assignFeatures;

    fprintf('Folder=%s\n', cell_compositing_all{i}{2});
    fprintf('Img=%s\n', cell_compositing_all{i}{3});
    fprintf('top_F=%f, top_B=%f, top_diff=%f\n', lum_high_F, lum_high_B, lum_high_F-lum_high_B);
    fprintf('low_F=%f, low_B=%f, low_diff=%f\n', lum_shdw_F, lum_shdw_B, lum_shdw_F-lum_shdw_B);
    fprintf('mean_F=%f, mean_B=%f, mean_diff=%f\n', lum_mean_F, lum_mean_B, lum_mean_F-lum_mean_B);
    fprintf('range_F=%f, range_B=%f\n', lum_range_F, lum_range_B);

    histF = [lum_portion_01_F, lum_portion_02_F, lum_portion_03_F, lum_portion_04_F, lum_portion_05_F, ...
             lum_portion_06_F, lum_portion_07_F, lum_portion_08_F, lum_portion_09_F, lum_portion_10_F, ...
             lum_portion_11_F, lum_portion_12_F, lum_portion_13_F, lum_portion_14_F, lum_portion_15_F, ...
             lum_portion_16_F, lum_portion_17_F, lum_portion_18_F, lum_portion_19_F, lum_portion_20_F, ...            
             ];
    histB = [lum_portion_01_B, lum_portion_02_B, lum_portion_03_B, lum_portion_04_B, lum_portion_05_B, ...
             lum_portion_06_B, lum_portion_07_B, lum_portion_08_B, lum_portion_09_B, lum_portion_10_B, ...
             lum_portion_11_B, lum_portion_12_B, lum_portion_13_B, lum_portion_14_B, lum_portion_15_B, ...
             lum_portion_16_B, lum_portion_17_B, lum_portion_18_B, lum_portion_19_B, lum_portion_20_B, ...            
             ];
    h = figure; 
    subplot(2,1, 1); plot([1:20], histF, 'r');
    subplot(2,1, 2); plot([1:20], histB, 'b');
    
    close(h);
         
    %% iteration continues
    index = index + 1;
end
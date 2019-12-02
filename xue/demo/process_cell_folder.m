close all; clc; clear all;

%% To process the cell_compositing_folder in case there are mistakes


fn = 'data\\folders.txt';

folderlist = textread(fn,'%s','delimiter','\n','whitespace','');

newLen = [xx xx xx];
% april21_static_outdoor_kendall
% static_indoor_mixed2
% static_office_bldg400
% static_outdoor_street_city_barcelona_spain_night
% static_submitted_bhattacharya2
% static_vancouver_canada_outdoor_street

index = 1;
for i = 1:length(folderlist)
    fn = sprintf('%s\\%s\\cell_compositing_folder.mat', path, folderlist{i});
    
    clear cell_compositing_folder;
    load( fn );   % load cell_compositing_folder for this folder
    
    nComp = length(cell_compositing_folder);
    new = newLen(i);
    
    cell_compositing_folder = cell_compositing_folder(1:new);
    
    disp( sprintf('original nComp = %d, newLen = %d, folder=%s', nComp, length(cell_compositing_folder), folderlist{i}) );
    
    %% Save shrinked cell_compositing_folder
    save( sprintf('data\\%s\\cell_compositing_folder.mat', folderlist{i}), 'cell_compositing_folder');    
end





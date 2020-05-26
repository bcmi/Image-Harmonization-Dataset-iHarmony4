close all; clc; clear all;

%%  Instruction
%  Merge 'cell_compositing_folder.mat' and 'cell_compositing_folder_add.mat'
%  to update 'cell_compositing_all'.
%
%%

option = 0;  %0: no cell_compositing_folder_add; 1: with cell_compositing_folder_add 

folderlist = textread('data\\imgFolderList.txt',  '%s','delimiter','\n','whitespace','');

index = 1;
for i = 1:length(folderlist)
    fn = sprintf('data\\%s\\cell_compositing_folder.mat', folderlist{i});
    if ~exist(fn,'file')   % a non-existing file
        disp('No exisiting cell_compositing_folder.mat');
        continue;
    end
    clear  cell_compositing_folder;
    load( fn );   % load cell_compositing_folder for this folder
    
    if option == 1
        fn = sprintf('data\\%s\\cell_compositing_folder_add.mat', folderlist{i});
        load( fn );   % load cell_compositing_folder_add for this folder
    end
    
    
    nComp = length(cell_compositing_folder);
    disp( sprintf('nComp = %d, folder=%s', nComp, folderlist{i}) );

    for p = 1:nComp
        %% Features 
        Features = cell_compositing_folder{p}{1};
        folderNm = cell_compositing_folder{p}{2};
        maskNm   = cell_compositing_folder{p}{3};
        
        %% Features to Add
        if option == 1
            Features_add = cell_compositing_folder_add{p}{1};
        end
        
        if option == 0
            cell_compositing_all{index} = {[Features], folderNm, maskNm};                       % a cell of featuers of all images
        elseif option == 1
            cell_compositing_all{index} = {[Features  Features_add], folderNm, maskNm};        % a cell of featuers of all images
        end
        
        index = index + 1;
    end
    
end
disp(sprintf('Total Index=%d', index));

delete ('data\\cell_compositing_all.mat');
save( 'data\\cell_compositing_all.mat', 'cell_compositing_all');
if option == 0
    disp('cell_compositing_all is updated WITHOUT cell_compositing_folder_add');
elseif option == 1
    disp('cell_compositing_all is updated WITH cell_compositing_folder_add');
end;



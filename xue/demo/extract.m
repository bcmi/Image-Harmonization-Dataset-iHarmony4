%% Select features for compositing match by LabelMe examples
close all; clc; clear all;

path = 'G:\My Study\ResearchProject\2011_ImageCompositing\Dataset\LabelMe\Images';

fn = sprintf('%s\\imgFolderList.txt', path);

folderlist = textread(fn,'%s','delimiter','\n','whitespace','');

for i = 1:length(folderlist)
    fprintf('FOLDER = %s\n', folderlist{i});
    fn = sprintf('%s\\%s\\pics.txt', path, folderlist{i});
    if ~exist(fn,'file')   % a non-existing file
        disp('No exisiting pics.txt');
        continue;
    end
    piclist = textread(fn,'%s','delimiter','\n','whitespace','');
    
    clear cell_compositing_folder;   %% Very important
    idx_folder = 1;
    
    for p = 1:length(piclist)
        if  isempty( strfind(piclist{p}, 'MASK') )       %% An original image I
            oriNm = strtrim(piclist{p}); % update the filename of an original image (NOT a mask)
            disp(sprintf('Ori_Img: %s', oriNm));

        else
            maskNm = strtrim(piclist{p});
            disp(sprintf('idx_folder: %d, Mask: %s', idx_folder, maskNm));
            
            if   isempty( strfind(maskNm, [oriNm, '_MASK']) )   
                disp('NOT MATCH: name of MASK and ori Name');
                continue;
            end

            % Load original image
            fn = sprintf('%s\\%s\\%s.jpg', path, folderlist{i}, oriNm);
            oriI = im2double(imread(fn));   % 0 ~ 1.0, 3 channel
            % figure; imshow(oriI);
            
            % Load original Mask
            fn = sprintf('%s\\%s\\%s.jpg', path, folderlist{i}, maskNm);
            oriMask = im2double(imread(fn));      % 0~1, 3channel  
            oriMask = oriMask(:,:,1);     % change to a single channel
            % figure; imshow(oriMask);
            
            %% prepare cropped image and mask
            [Mask, I_bright, I_lCntrst, I_cct, I_S, I_H] = prepImg_input(oriMask, oriI);
            if sum(sum(Mask)) < 1000
                disp('Skip: Too Small Masked object (area<1000)!');
                continue;
            end
            clear oriI; clear oriMask;
            
            %% Calculate features of fg and bg 
            fgbgFeatures = calcFeaturesAfterPrep(Mask, I_bright, I_lCntrst, I_cct, I_S, I_H);
            
            %% Check 
%             a = fgbgFeatures(1, 9) - sum(fgbgFeatures(1, 10:14));  %Lum
%             b = 1 - sum(fgbgFeatures(1, 62:69));                   % cct
%             c = 1 - sum(fgbgFeatures(1, 101:108));                 % hue
%             d = fgbgFeatures(1, 78) - sum(fgbgFeatures(1, 79:83)); %sat
%             fprintf('a=%f, b=%f, c=%f, d=%f \n', a, b, c, d);
            
            %% Save to cell
            % cell for each folder
            cc = cell(1, 3);
            cc{1} = fgbgFeatures;
            cc{2} = folderlist{i};
            cc{3} = maskNm;
            cell_compositing_folder{idx_folder} = cc;

            idx_folder = idx_folder + 1;    %index for images in this folder
        end  % elseif mask image
        
        
    end % for each pic
    
    delete ( sprintf('data\\%s\\cell_compositing_folder.mat', folderlist{i})  );
    save(    sprintf('data\\%s\\cell_compositing_folder.mat', folderlist{i}), 'cell_compositing_folder');
    
end % for each folder

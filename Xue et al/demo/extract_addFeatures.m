%%% Extract more features in addition to those done by 'main.m'

%% Select features for compositing match by LabelMe examples
close all; clc; clear all;

path = 'E:\My Study\Research_Projects\2011_ImageCompositing\Dataset\LabelMe\Images';

fn = sprintf('%s\\folders.txt', path);

folderlist = textread(fn,'%s','delimiter','\n','whitespace','');

index = 1;

for i = 1:length(folderlist)
    fn = sprintf('%s\\%s\\pics.txt', path, folderlist{i});
    piclist = textread(fn,'%s','delimiter','\n','whitespace','');
    
    clear cell_compositing_folder_add;   %% Very important to clear
    idx_folder = 1;
    
    for p = 1:length(piclist)
        fn = sprintf('%s\\%s\\%s.jpg', path, folderlist{i}, strtrim(piclist{p}));
        img = imread(fn);
        % figure; imshow(img);

        if  isempty( strfind(piclist{p}, 'MASK') )       %% An original image I
            %% Update and Regularize the original image, I
            I = double(img)./255.0;   % 0 ~ 1.0
            I_GammaInv = imadjust(I, [0 0 0;1 1 1], [0 0 0;1 1 1], 2.2); % inverse Gamma (LDR->HDR)

            fsz = round( min(size(I,1), size(I,2))/125 );  % given min(wid,ht)=400, fsz = 3
            filter = fspecial('gaussian', fsz, 0.5);
            I_ready = imfilter(I_GammaInv, filter, 'replicate');      % ** The final ready-to-use input **
            % figure; imshow(I_ready);
            
            %% Calc different image projections
            %I_bright        = I_ready(:,:,1)*0.333 + I_ready(:,:,2)*0.334 + I_ready(:,:,3)*0.3333; 
            %figure; imshow(I_bright);
            
            %I_lCntrst       = calcLocalCntrst_Bright(I_bright);
            %figure; imshow(I_lCntrst);
            
            %I_cct           = calcCCTimg( I_ready ) .^(-1) * 1000000;
            %figure; imshow(I_cct /max(max(I_cct)) );
            
            %I_cct_lCntrst   = calcLocalCntrst_CCT(I_cct);
            %figure; imshow(I_cct_lCntrst /max(max(I_cct_lCntrst)) );
                        
            I_lab           = applycform(I_ready, makecform('srgb2lab')); 
            I_L             = I_lab(:,:,1);
            I_a             = I_lab(:,:,2);
            I_b             = I_lab(:,:,3);
            %figure; imshow(I_lab);
            
            disp(sprintf('Ori_Img: %s', fn));
            
        else
            %% A mask image, Mask
            Mask = double(img)./255.0;
            Mask = Mask(:,:,1);     % change to a single channel
            % figure; imshow(Mask);
            
            %% %% %% %%  Forground Features
            
            %% Lab Histogram
            nBin = 100;
            vL = sort( I_L( Mask>=0.005 ), 'descend');  % the masked out area of fg, brightness
            mean_L_F = mean(vL);
            std_L_F  = std(vL);
            % hist L
            xL = linspace(0, 100, nBin);    % L
            cnts_L_F = hist(vL, xL);
            prob_L_F = cnts_L_F / sum(cnts_L_F);

            va = sort( I_a( Mask>=0.005 ), 'descend');  % the masked out area of fg, brightness
            mean_a_F = mean(va);
            std_a_F  = std(va);
            % hist a
            xa = linspace(-100, 100, nBin); % a
            cnts_a_F = hist(va, xa);
            prob_a_F = cnts_a_F / sum(cnts_a_F);

            vb = sort( I_b( Mask>=0.005 ), 'descend');  % the masked out area of fg, brightness
            mean_b_F = mean(vb);
            std_b_F  = std(vb);
            % hist b
            xb = linspace(-100, 100, nBin); % b
            cnts_b_F = hist(vb, xb);
            prob_b_F = cnts_b_F / sum(cnts_b_F);
            
            
            %% %% %%  Backround Features  
            
            %% Find a Local mask as the background
            BW = im2bw(Mask, 0.7);  % binary mask, a logical array; thrshhold in 0~1
            
            STATS = regionprops(BW, 'BoundingBox');
            bndbx       = STATS.BoundingBox;
            cx = bndbx(1);      cy  = bndbx(2);       % x, L->R; y, up->down, upper-left corner of bndbox
            xwid = bndbx(3);    ywid  = bndbx(4);     % size of the bounding box 
            
            len_crop = 3;  % len x len bndbox around the FG is considered as BG.
            sx = cx - (len_crop-1)/2*xwid;  sy = cy - (len_crop-1)/2*ywid;    % upper-left corner 
            tx = cx + (len_crop+1)/2*xwid;  ty = cy + (len_crop+1)/2*ywid;    % bottom-right corner
            
            sx = round(max(sx,1));   sy = round(max(sy,1));
            tx = round(min(tx,size(BW,2)));   ty = round(min(ty,size(BW,1)));
            
            %figure; imshow(BW); hold on;
            %rectangle('Position', [sx,sy,tx-sx,ty-sy],'EdgeColor','y');
            
            updtMask = ones(size(Mask));
            updtMask(sy:ty, sx:tx) = 0;
            Mask = Mask + updtMask;
            %figure; imshow(Mask);

            
            %% Lab Histogram
            nBin = 100;
            vL = sort( I_L( Mask<0.005 ), 'descend');  % the masked out area of fg, brightness
            mean_L_B = mean(vL);
            std_L_B  = std(vL);
            % hist L
            xL = linspace(0, 100, nBin);    % L
            cnts_L_B = hist(vL, xL);
            prob_L_B = cnts_L_B / sum(cnts_L_B);

            va = sort( I_a( Mask<0.005 ), 'descend');  % the masked out area of fg, brightness
            mean_a_B = mean(va);
            std_a_B  = std(va);
            % hist a
            xa = linspace(-100, 100, nBin); % a
            cnts_a_B = hist(va, xa);
            prob_a_B = cnts_a_B / sum(cnts_a_B);

            vb = sort( I_b( Mask<0.005 ), 'descend');  % the masked out area of fg, brightness
            mean_b_B = mean(vb);
            std_b_B  = std(vb);
            % hist b
            xb = linspace(-100, 100, nBin); % b
            cnts_b_B = hist(vb, xb);
            prob_b_B = cnts_b_B / sum(cnts_b_B);
            
            
            %% %% Difference Features %% %% 
            
            %% Chi Square in Lab
            chi2_lab = 0.5*(    sum( (prob_L_F - prob_L_B).^2 ./ (prob_L_F + prob_L_B + 1e-9)  ) ...
                             +  sum( (prob_a_F - prob_a_B).^2 ./ (prob_a_F + prob_a_B + 1e-9)  ) ...
                             +  sum( (prob_b_F - prob_b_B).^2 ./ (prob_b_F + prob_b_B + 1e-9)  ) ...
                            );
            

            
            %% %% Save to cell
            cell_compositing_folder_add{idx_folder} = [ mean_L_F, std_L_F, mean_a_F, std_a_F, mean_b_F, std_b_F, chi2_lab;  ...
                                                        mean_L_B, std_L_B, mean_a_B, std_a_B, mean_b_B, std_b_B, chi2_lab  ...                        
                                                      ];
            %% cell for each folder                                  
            %cell_compositing{index} = cell_compositing_folder_add{idx_folder};      
            
            disp(sprintf('Idx: %d, idx_folder: %d, Mask: %s', index, idx_folder, fn));
            
            
            index = index + 1;              %index for all images
            idx_folder = idx_folder + 1;    %index for images in this folder
          
        end  % elseif mask image
        
        
    end % for each pic
    
    save( sprintf('data\\%s\\cell_compositing_folder_add.mat', folderlist{i}), 'cell_compositing_folder_add');
    
end % for each folder

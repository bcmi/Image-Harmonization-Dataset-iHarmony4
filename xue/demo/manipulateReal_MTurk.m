close all; clc; clear all;

goals = {'sat'};  %  'lum', 'sat', 'hue', 'cntrst', 'cct'

path = 'G:\My Study\ResearchProject\2011_ImageCompositing\Dataset\Experiments\Stimuli_Adjust\';
fn = sprintf('%s\\pics_actual.txt', path);       
piclist = textread(fn,'%s','delimiter','\n','whitespace','');
nPic = length(piclist);


nStp = 3;  % actually 2*3+1 levels
for p=1:nPic 
   picnm = strtrim( piclist{p} );
   disp(sprintf('pic = %s', picnm));
   fn = sprintf('%s\\%s.jpg', path, picnm);
   oriI = im2double(imread(fn));   % 0 ~ 1.0, 3 channel
   % figure; imshow(oriI);
   
   if size(oriI,2)>=size(oriI,1)  % 2 is wid (nCols), 1 is ht (nRows)
       newWid = 600;
       newHt  = round(size(oriI,1)*600/size(oriI,2));
   else
       newHt = 600;
       newWid  = round(size(oriI,2)*600/size(oriI,1));
   end
   %Load original Mask
   fn = sprintf('%s\\MaskOri\\%s_Mask.jpg', path, picnm);
   oriMask = im2double(imread(fn));      % 0~1, 3channel  
   oriMask = oriMask(:,:,1);     % change to a single channel_
  
   for g=1:length(goals)
       goal = goals{g};
       disp(sprintf('goal = %s', goal));
       for i= -nStp:1:nStp,
         for j= -nStp:1:nStp,
               switch goal
                   case 'lum',
                       step = 0.5;     %by stop
                   case 'cntrst',
                       step = 0.075;     %0.15 for top cntrst only
                   case 'cct',
                       step = 40;   %by mired
                   case 'sat',
                       step = 0.25;     %by stop
                       folder = 'Saturation'; 
                   case 'hue',
                       step = 0.075;  %by 0~1
               end
               
               shift_f = i*step;   
               shift_b = j*step;   
               
               outI = manipulateFeature(goal, oriI, oriMask, shift_f, shift_b);

               outI = imresize(outI, [newHt, newWid]);
               
               fn   = sprintf('%s\\%s\\%s\\%d_%d.jpg', path, folder, picnm, i+nStp, j+nStp);
               imwrite( outI, fn, 'jpg');
               disp(sprintf('%d_%d Saved\n', i+nStp, j+nStp));
         end
       end
   end  % for goals
end % for nPic
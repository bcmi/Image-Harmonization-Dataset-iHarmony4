close all; clc; clear all;

goals = {'cntrst', 'cct'};  %  'lum', 'sat', 'hue'

path = 'G:\My Study\ResearchProject\2011_ImageCompositing\Dataset\Experiments\Manipulated\';
fn = sprintf('%s\\pics.txt', path);       
piclist = textread(fn,'%s','delimiter','\n','whitespace','');
nPic = length(piclist);

for p=1:nPic 
   picnm = strtrim( piclist{p} );
   disp(sprintf('pic = %s', picnm));
   fn = sprintf('%s\\%s\\3_3.jpg', path, picnm);
   oriI = im2double(imread(fn));   % 0 ~ 1.0, 3 channel
   % figure; imshow(oriI);
            
   %Load original Mask
   fn = sprintf('%s\\%s\\Mask.jpg', path, picnm);
   oriMask = im2double(imread(fn));      % 0~1, 3channel  
   oriMask = oriMask(:,:,1);     % change to a single channel_
  
   for g=1:length(goals)
       goal = goals{g};
       disp(sprintf('goal = %s', goal));
       for i=[0,1,2]
         for j=[0,1,2]
               switch goal
                   case 'lum',
                       step = 1.5;     %by stop
                   case 'cntrst',
                       step = 0.15;     %0.15 for top cntrst only
                   case 'cct',
                       step = 100;   %by mired
                   case 'sat',
                       step = 0.75;     %by stop
                   case 'hue',
                       step = 0.15;  %by 0~1
               end
               
               shift_f = -step + i*step;   
               shift_b = -step + j*step;   
               
               outI = manipulateFeature(goal, oriI, oriMask, shift_f, shift_b);
               fn   = sprintf('%s\\%s\\%s\\%d_%d.jpg', path, picnm, goal, i, j);
               imwrite( outI, fn, 'jpg');
         end
       end
   end  % for goals
end % for nPic
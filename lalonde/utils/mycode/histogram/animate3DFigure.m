%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function animate3DFigure(figHangle, increment, doSave, file)
%   Visualize a 3-D figure by rotating along vertical axis
% 
% Input parameters:
%   - figHandle: handle to the 3-D plot to rotate
%   - increment: Variation in angle from one frame to the next
%   - doSave: whether to save the animation or not (animated gif)
%   - file: file to use to save the animation
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function animate3DFigure(figHandle, increment, doSave, file) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(figHandle);

[az,el] = view;
for i=1:increment:360
    view(az+i, el);
    
    drawnow;
    pause(0.5);
    
    if doSave
        saveas(gcf, sprintf('file_%d.png', i));
    end
end

% build the animated gif from the saved files
if doSave
    fprintf('Saving animated gif...');
    for i=1:increment:360
        filename = sprintf('file_%d.png', i);
        img = imread(filename);
        img = imresize(img, 0.3);
        [X, map] = rgb2ind(img, 256);
        if i==1
            imwrite(X, map, file, 'WriteMode', 'overwrite', 'LoopCount', inf, 'DelayTime', 0.1);
        else
            imwrite(X, map, file, 'WriteMode', 'append');
        end
        delete(filename);
    end
    
    fprintf('done.\n');
    close;
end
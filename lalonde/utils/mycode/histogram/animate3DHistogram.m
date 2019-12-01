%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function animate3DHistogram(hist, dim, duration, equalize, reverse, doSave, file)
%   Visualize a 3-D histogram by successively showing 2-D slices. 
% 
% Input parameters:
%   - figHandle: handle to the figure used to display the animation
%   - hist: 3-D histogram
%   - dim: dimension along which the slices will be taken
%   - duration: total duration over which the entire histogram will be
%     displayed (in practice, it will be a little longer, because this
%     doesn't take the display time into account)
%   - equalize: normalize wrt to entire histogram (1) or each slice independently (0)
%   - reverse: loop back at the end
%   - doSave: whether to save the animation or not (animated gif)
%   - file: file to use to save the animation
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function animate3DHistogram(figHandle, hist, dim, duration, equalize, reverse, doSave, file) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(figHandle);

for i=1:3
    ind{i} = 1:size(hist,i);
end

timeDelta = duration ./ size(hist, dim);
lims = [min(hist(:)) max(hist(:))];

order = 1:size(hist, dim);
for i=order
    ind{dim} = i;
    title(sprintf('%d', i));
    image(squeeze(hist(ind{:})), 'CDataMapping', 'scaled');
    if equalize
        set(gca, 'CLim', lims);
    end
    title(sprintf('%d', i));
    drawnow;
    pause(timeDelta);
    
    if doSave
        saveas(gcf, sprintf('file_%d.png', i));
    end
end

if reverse
    for i=fliplr(order)
        ind{dim} = i;
        title(sprintf('%d', i));
        image(squeeze(hist(ind{:})), 'CDataMapping', 'scaled');
        if equalize
            set(gca, 'CLim', lims);
        end
        title(sprintf('%d', i));
        drawnow;
        pause(timeDelta);
        
        if doSave
            saveas(gcf, sprintf('file_r%d.png', i));
        end
    end
end

% build the animated gif from the saved files
if doSave
    fprintf('Saving animated gif...');
    for i=order
        filename = sprintf('file_%d.png', i);
        img = imread(filename);
        img = imresize(img, 0.5);
        [X, map] = rgb2ind(img, 256);
        if i==1
            imwrite(X, map, file, 'WriteMode', 'overwrite', 'LoopCount', inf, 'DelayTime', 0);
        else
            imwrite(X, map, file, 'WriteMode', 'append');
        end
        delete(filename);
    end
    
    if reverse
        for i=fliplr(order)
            filename = sprintf('file_r%d.png', i);
            img = imread(filename);
            img = imresize(img, 0.5);
            [X, map] = rgb2ind(img, 256);
            imwrite(X, map, file, 'WriteMode', 'append');

            delete(filename);
        end
    end
    
    fprintf('done.\n');
    close;
end



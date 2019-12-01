function code

    % Read the sample image in
    im = imread('shapessm.jpg');
    
    % Find edges using the Canny operator with hysteresis thresholds of 0.1
    % and 0.2 with smoothing parameter sigma set to 1.
    edgeim = edge(im,'canny', [0.1 0.2], 1);

    figure(1), imshow(edgeim); % truesize(1)
    
    % Link edge pixels together into lists of sequential edge points, one
    % list for each edge contour.  Discard contours less than 10 pixels long.
    [edgelist, labelededgeim] = edgelink(edgeim, 10);
    
    % Display the labeled edge image with random colours for each
    % distinct edge in figure 2
    drawedgelist(edgelist, size(im), 1, 'rand', 2); axis off        
    
    % Fit line segments to the edgelists 
    tol = 2;         % Line segments are fitted with maximum deviation from
		     % original edge of 2 pixels.
    seglist = lineseg(edgelist, tol);

    % Draw the fitted line segments stored in seglist in figure window 3 with
    % a linewidth of 2 and random colours
    drawedgelist(seglist, size(im), 2, 'rand', 3); axis off
    


    if 0
    figure(1), print -djpeg -r0 edgeim.jpg
    figure(2), print -djpeg -r0 edgelistim.jpg
    figure(3), print -djpeg -r0 segmentim.jpg    
    end
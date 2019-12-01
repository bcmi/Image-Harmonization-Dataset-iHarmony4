% DISPFEAT - Displays feature types as detected by PHASECONG.
%
% This function provides a visualisation of the feature types as detected
% by PHASECONG.
%
% Usage:  im = dispfeat(ft, edgeim, 'l')
%
% Arguments:  ft     - An image providing the local weighted mean 
%                      phase angle at every point in the image for the 
%                      orientation having maximum energy.  This image can be
%                      complex valued in which case phase is assumed to be
%                      the complex angle, or it can be real valued, in which
%                      case it is assumed to be the phase directly.
%             edgeim - A binary edge image (typically obtained via
%                      non-maxima suppression and thresholding).
%                      This is used as a `mask' to specify which bits of
%                      the phase data should be displayed.
%                      Alternatively you can supply a phase congruency
%                      image in which case it is used to control the
%                      saturation of the colour coding
%             l      - An optional parameter indicating that a line plot
%                      encoded by line style should also be produced. If
%                      this is the case then `edgeim' really should be an
%                      edge image.
% 
% Returns:    im     - An edge image with edges colour coded according to
%                      feature type. 
%
% Two or three plots are generated:
% 1. An edge image with edges colour coded according to feature type.
% 2. A histogram of the frequencies at which the different feature types
%    occur. 
% 3. Optionally a black/white edge image with edges coded by different line
%    styles.  Not as pretty as the first plot, but it is something that can
%    be put in a paper and reproduced in black and white.

% Copyright (c) 2001-2009 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% http://www.csse.uwa.edu.au/
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% June 2001  Original version
% May  2009  Allowance for phase data 'ft' to be real or complex valued.

function im = dispfeat(ft, edgeim)

% Construct the colour coded image

    maxhue = 0.7;             % Hues vary from 0 (red) indicating line feature to 
		              % 0.7 (blue) indicating a step feature.
    nhues = 50;     
    
    if ~isreal(ft)    % Phase is encoded as complex values
	phaseang = angle(ft);     
    else
	phaseang = ft;  % Assume data is phase already
    end
		    
    % Map -ve phase angles to 0-pi
    negphase = phaseang<0;
    phaseang = negphase.*(-phaseang) + ~negphase.*phaseang; 
    
    % Then map angles > pi/2 to 0-pi/2
    x = phaseang>(pi/2);                      
    phaseang = x.*(pi-phaseang) + ~x.*phaseang;
    
    % Now set up a HSV image and convert to RGB
    hsvim(:,:,1) = (pi/2-phaseang)/(pi/2)*maxhue;
    hsvim(:,:,2) = edgeim;           % saturation
    hsvim(:,:,3) = 1;
    
    hsvim(1,:,3) = 0;
    hsvim(end,:,3) = 0;    
    hsvim(:,1,3) = 0;
    hsvim(:,end,3) = 0;        
    
    im = hsv2rgb(hsvim);

    % Set up the colour key bar
    keybar(:,:,1) = [maxhue:-maxhue/nhues:0]';
    keybar(:,:,2) = 1;
    keybar(:,:,3) = 1;
    keybar = hsv2rgb(keybar);

    % Plot the results
    figure(1), clf
    subplot('position',[.05 .1 .75 .8]), imshow(im)
    subplot('position',[.8 .1 .1 .8]), imshow(keybar)

    text(3,2,'step feature');
    text(3,nhues/2,'step/line');
    text(3,nhues,'line feature');

% Construct the histogram of feature types

    figure(2),clf
    data = phaseang(find(edgeim));  % find phase angles just at edge points

    Nbins = 32;
    bincentres = [0:pi/2/Nbins:pi/2];

    hdata = histc(data(:), bincentres);
    bar(bincentres+pi/4/Nbins, hdata)      % plot histogram

    ymax = max(hdata);
    xlabel('phase angle'); ylabel('frequency');
    ypos = -.12*ymax;
    axis([0 pi/2 0 1.05*ymax])

if nargin == 3
    
% Construct the feature type image coded using different line styles

    % Generate a phase angle image with non-zero values only at edge
    % points.  An offset of eps is added to differentiate points having 0
    % phase from non edge points.
    featedge = (phaseang+eps).*double(edgeim);

    % Now construct feature images over specified phase ranges
    f1 = featedge >= eps    & featedge < pi/6;
    f2 = featedge >= pi/6   & featedge < pi/3;
    f3 = featedge >= pi/3   & featedge <= pi/2;
    
    fprintf('Linking edges for plots...\n');
    [f1edgelst dum] = edgelink(f1,2);
    [f2edgelst dum] = edgelink(f2,2);
    [f3edgelst dum] = edgelink(f3,2);

    figno = 3;
    figure(figno), clf

    % Construct a legend by first drawing some dummy, zero length, lines
    % with the appropriate linestyles in the right order
    line([0 0],[0 0],'LineStyle','-');
    line([0 0],[0 0],'LineStyle','--');
    line([0 0],[0 0],'LineStyle',':');
    legend('step', 'step/line', 'line',3);

    % Now do the real plots
    plotedgelist(f1edgelst, figno, '-');
    plotedgelist(f2edgelst, figno, '--');
    plotedgelist(f3edgelst, figno, ':');

    % Draw a border around the whole image
    [r c] = size(edgeim);
    line([0 c c 0 0],[0 0 r r 0]);
    axis([0 c 0 r])
    axis equal
    axis ij
    axis off
    
end


%------------------------------------------------------------------------    
% Internal function to plot an edgelist as generated by edgelink using a
% specified linestyle

function plotedgelist(elist, figno, linestyle)

    figure(figno);
    for e = 1:length(elist)
       line(elist{e}(:,2), elist{e}(:,1), 'LineStyle', linestyle, ...
	    'LineWidth',1);
    end

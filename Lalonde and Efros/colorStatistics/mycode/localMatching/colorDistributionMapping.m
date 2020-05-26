function colorDistribution
%%
addpath ../;
setPath;

close all;
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/illuminationContext/concatHistograms';

doSave = 1;
nbBins = 50;

%% Build a RGB cube
div = 16;
[r,g,b]=meshgrid(0:div:255,0:div:255,0:div:255);

%% Plot the RGB cube in space
figRgb = figure(1);
scatter3(r(:), g(:), b(:), 20, [r(:) g(:) b(:)]./255, 'filled');
title(sprintf('RGB space regularly sampled at every %d bins', div));
axis([0 255 0 255 0 255]);
xlabel('R'), ylabel('G'), zlabel('B');

%% Animate the figure
if doSave
%     animate3DFigure(figRgb, 2, doSave, 'plotRgb.gif');
end

%% Convert to LAB
figLab = figure(2);
[L,A,B] = rgb2lab(r, g, b);
scatter3(L(:), A(:), B(:), 20, [r(:) g(:) b(:)]./255, 'filled');
title('LAB mapping');
axis([0 100 -100 100 -100 100]);
xlabel('L'), ylabel('A'), zlabel('B');

%% Animate the figure
if doSave
%     animate3DFigure(figLab, 2, doSave, 'plotLab.gif');
end

%% Convert to HSV
figHsv = figure(3);
hsv = rgb2hsv([r(:), g(:), b(:)]./255); H = hsv(:,1); S = hsv(:,2); V = hsv(:,3);
scatter3(H(:), S(:), V(:), 20, [r(:) g(:) b(:)]./255, 'filled');
title('HSV mapping');
axis([0 1 0 1 0 1]);
xlabel('H'), ylabel('S'), zlabel('V');

%% Animate the figure
if doSave
%     animate3DFigure(figHsv, 2, doSave, 'plotHsv.gif');
end

%% Convert to XYZ
figXyz = figure(4);
[X,Y,Z] = rgb2xyz(r(:), g(:), b(:));
scatter3(X(:), Y(:), Z(:), 20, [r(:) g(:) b(:)]./255, 'filled');
title('XYZ mapping');
axis([0 1 0 1 0 1]);
xlabel('X'), ylabel('Y'), zlabel('Z');

%% Animate the figure
if doSave
    animate3DFigure(figXyz, 2, doSave, 'plotXYZ.gif');
end

%% Convert to LMS
figLms = figure(5);
[L,M,S] = xyz2lms(X(:), Y(:), Z(:));
scatter3(L(:), M(:), S(:), 20, [r(:) g(:) b(:)]./255, 'filled');
title('LMS mapping');
axis([0 1 0 1 0 1]);
xlabel('L'), ylabel('M'), zlabel('S');

%% Animate the figure
if doSave
    animate3DFigure(figLms, 2, doSave, 'plotLMS.gif');
end


%% Convert to lAlphaBeta
figLalphabeta = figure(6);
[l,alpha,beta] = rgb2lalphabeta(r(:), g(:), b(:));
scatter3(l(:), alpha(:), beta(:), 20, [r(:) g(:) b(:)]./255, 'filled');
title('l\alpha\beta mapping');
axis([-10 0 -3 3 -0.5 0.5]);
xlabel('L'), ylabel('\alpha'), zlabel('\beta');

%% Animate the figure
if doSave
    animate3DFigure(figLalphabeta, 2, doSave, 'plotLalphabeta.gif');
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get denser sampling
div = 1;
[r,g,b]=meshgrid(0:div:255,0:div:255,0:div:255);
[L,A,B] = rgb2lab(r(:), g(:), b(:));
[l,alpha,beta] = rgb2lalphabeta(r(:), g(:), b(:));
% hsv = rgb2hsv([r(:), g(:), b(:)]./255); H = hsv(:,1); S = hsv(:,2); V = hsv(:,3);

%% Histogram the points in LAB, and keep only the non-empty bins 
labHisto = myHistoND([L(:) A(:) B(:)], nbBins, [0 -100 -100], [100 100 100]);
indActiveLab = find(labHisto);
occ = length(indActiveLab) / numel(labHisto);

save(fullfile(outputBasePath, sprintf('indActiveLab_%d.mat', nbBins)), 'indActiveLab');

fprintf('Lab occupancy: %f\n', occ);

%% Histogram the points in L-alpha-beta, and keep only the non-empty bins 
lalphabetaHisto = myHistoND([l(:) alpha(:) beta(:)], nbBins, [-10 -3 -0.5], [0 3 0.5]);
indActiveLalphabeta = find(lalphabetaHisto);
occ = length(indActiveLalphabeta) / numel(lalphabetaHisto);

save(fullfile(outputBasePath, sprintf('indActiveLalphabeta_%d.mat', nbBins)), 'indActiveLalphabeta');

fprintf('Lalphabeta occupancy: %f\n', occ);

%% Animate the histogram
% animate3DHistogram(labHisto, 1, 10, 1, 1, 1, 'labHisto.gif');


%% Histogram the points in HSV, and keep only the non-empty bins 
hsvHisto = myHistoND([H(:) S(:) V(:)], nbBins, [0 0 0], [1 1 1]);
indActiveHsv = find(hsvHisto);
occ = length(indActiveHsv) / numel(hsvHisto);

save(fullfile(outputBasePath, sprintf('indActiveHsv_%d.mat', nbBins)), 'indActiveHsv');

fprintf('Hsv occupancy: %f\n', occ);

%% Animate the histogram
% animate3DHistogram(hsvHisto, 1, 10, 1, 1, 1, 'hsvHisto.gif');


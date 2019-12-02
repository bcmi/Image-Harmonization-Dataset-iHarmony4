
% This code demonstrates how the boundary matching code works,
% and how the benchmark uses it.  This is not meant to show
% how to run the benchmark.  See the README file for that.

% setup
present = 'color';
iid = 101085;
nthresh = 10;

% read the image
im = rgb2gray(double(imread(imgFilename(iid)))/255);
figure(1); clf;
imshow(im);

% create a pb image 
%pb = pbNitzberg(im);
pb = pbGM(im);
figure(2); clf;
imagesc(pb,[0 1]); 
axis image; axis off; truesize;

% read segmentations
segs = readSegs(present,iid);

% match the first seg and a thresholded pb
bmap1 = double(seg2bmap(segs{1}));
bmap2 = double(pb > 0.5);
[match1,match2,cost,oc] = correspondPixels(bmap1,bmap2,0.01,1000);
h=figure(3); clf;
plotMatch(h,bmap1,bmap2,match1,match2);
title('Seg1 vs. Pb>0.5','Color',[1 1 1]);

% compare the pb and segs
[thresh,cntR,sumR,cntP,sumP] = boundaryPR(pb,segs,nthresh);

% precision/recall plot
r = cntR./(sumR+(sumR==0));
p = cntP./(sumP+(sumP==0));
f = 2.*r.*p./(r+p+((r+p)==0));
figure(4); clf;
plot(r,p,'-o');
axis equal; axis([0 1 0 1]);
xlabel('Recall'); ylabel('Precision');

% find best F-measure (should interpolate)
[t,idx] = max(f(:));
title(sprintf('F=%.2g at (R,P)=(%.2g,%.2g) t=%.2g',...
              f(idx),r(idx),p(idx),thresh(idx)));

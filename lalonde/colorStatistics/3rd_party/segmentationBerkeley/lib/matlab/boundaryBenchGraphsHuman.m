function boundaryBenchGraphsHuman(pbDir)
% function boundaryBenchGraphsHuman(pbDir)
%
% Create graphs, after boundaryBenchHuman has been run.
%
% See also boundaryBenchHuman.
%
% David Martin <dmartin@eecs.berkeley.edu>
% July 2003

iids = imgList('test');
n = numel(iids);

% read in all the data
fwrite(2,'Reading data ');
progbar(0,n);
prPairs = cell(n,1);
prAllPairs = zeros(0,3);
for i = 1:n,
  iid = iids(i);
  fname = fullfile(pbDir,sprintf('%d_pr.txt',iid));
  x = dlmread(fname);
  prPairs{i} = x(:,1:3);
  prAllPairs = vertcat(prAllPairs,prPairs{i});
  progbar(i,n);
end
fname = fullfile(pbDir,'scores.txt');
x = dlmread(fname);
prImages = x(:,1:4);
fname = fullfile(pbDir,'score.txt');
x = dlmread(fname);
prTotal = x(1:3);

% create the overall PR graph
h = figure; clf; hold on;
prplot(h,prAllPairs(:,1),prAllPairs(:,2),'k.',4,1); 
prplot(h,prImages(:,2),prImages(:,3),'kx',7,1); 
prplot(h,prTotal(1),prTotal(2),'wo',10,1);
title(sprintf('F=%4.2f',prTotal(3))); 
lh = legend('Subjects','Images','Overall',3);
p = get(lh,'Position');
p(1) = .225;
set(lh,'Position',p);
print(h,'-depsc2',fullfile(pbDir,'pr.eps'));
print(h,'-djpeg95','-r36',fullfile(pbDir,'pr_half.jpg'));
print(h,'-djpeg95','-r0',fullfile(pbDir,'pr_full.jpg'));

for i = 1:n,
  iid = iids(i);
  if iid~=prImages(i,1), error('bug'); end
  fprintf(2,'Processing image %d/%d (iid=%d)...\n',i,n,iid);

  % create PR graphs for this image
  fname = fullfile(pbDir,sprintf('%d_pr.txt',iid));
  figure(h); clf; hold on;
  prplot(h,prPairs{i}(:,1),prPairs{i}(:,2),'k.',7,1);
  prplot(h,prImages(i,2),prImages(i,3),'kx',9,2);
  title(sprintf('%d F=%4.2f',iid,prImages(i,4))); 
  lh = legend('Subjects','Image',3);
  p = get(lh,'Position');
  p(1) = .225;
  set(lh,'Position',p);
  print(h,'-depsc2',fullfile(pbDir,sprintf('%d_pr.eps',iid)));
  print(h,'-djpeg95','-r36',fullfile(pbDir,sprintf('%d_pr_half.jpg',iid)));
  print(h,'-djpeg95','-r0',fullfile(pbDir,sprintf('%d_pr_full.jpg',iid)));
end

function prplot(h,r,p,sym,sz,w)
figure(h);
plot(r,p,sym,'MarkerFaceColor','k','MarkerSize',sz,'LineWidth',w);
box on;
grid on;
set(gca,'Fontsize',12);
set(gca,'XTick',[0 .25 .5 .75 1]);
set(gca,'YTick',[0 .25 .5 .75 1]);
set(gca,'XGrid','on');
set(gca,'YGrid','on');
xlabel('Recall');
ylabel('Precision');
axis square;
axis([0 1 0 1]);


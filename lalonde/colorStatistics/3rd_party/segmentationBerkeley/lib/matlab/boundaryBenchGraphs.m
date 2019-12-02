function boundaryBenchGraphs(pbDir)
% function boundaryBenchGraphs(pbDir)
%
% Create graphs, after boundaryBench(pbDir) has been run.
%
% See also boundaryBench.
%
% David Martin <dmartin@eecs.berkeley.edu>
% May 2003

fname = fullfile(pbDir,'scores.txt');
scores = dlmread(fname); % iid,thresh,r,p,f
fname = fullfile(pbDir,'score.txt');
score = dlmread(fname); % thresh,r,p,f

% create the overall PR graph
fname = fullfile(pbDir,'pr.txt');
pr = dlmread(fname); % thresh,r,p,f
h = figure(1); clf; hold on;
prplot(h,pr(:,2),pr(:,3),sprintf('F=%4.2f',score(4)));
ph=plot(score(2),score(3),'ko','MarkerFaceColor','k','MarkerSize',10);
lh=legend(ph,sprintf('F=%4.2f @(%4.2f,%4.2f) t=%4.2f',...
                     score(4),score(2),score(3),score(1)));
p=get(lh,'Position');
p(1)=0.25;
p(2)=0.15;
set(lh,'Position',p);
print(h,'-depsc2',fullfile(pbDir,'pr.eps'));
print(h,'-djpeg95','-r36',fullfile(pbDir,'pr_half.jpg'));
print(h,'-djpeg95','-r0',fullfile(pbDir,'pr_full.jpg'));
%close(h);

iids = imgList('test');
for i = 1:numel(iids),
  iid = iids(i);
  fprintf(2,'Processing image %d/%d (iid=%d)...\n',i,numel(iids),iid);

  % create PR graphs for this image
  fname = fullfile(pbDir,sprintf('%d_pr.txt',iid));
  pri = dlmread(fname);
  h = figure(1); clf; hold on;
  prplot(h,pri(:,2),pri(:,3),sprintf('%d F=%4.2f',iid,scores(i,5)));
  ph=plot(scores(i,3),scores(i,4),'ko','MarkerFaceColor','k','MarkerSize',10);
  lh=legend(ph,sprintf('F=%4.2f @(%4.2f,%4.2f) t=%4.2f',...
                       scores(i,5),scores(i,3),scores(i,4),scores(i,2)));
  p=get(lh,'Position');
  p(1)=0.25;
  p(2)=0.15;
  set(lh,'Position',p);
  print(h,'-depsc2',fullfile(pbDir,sprintf('%d_pr.eps',iid)));
  print(h,'-djpeg95','-r36',fullfile(pbDir,sprintf('%d_pr_half.jpg',iid)));
  print(h,'-djpeg95','-r0',fullfile(pbDir,sprintf('%d_pr_full.jpg',iid)));
  %close(h);
end

function prplot(h,r,p,ti)
figure(h); 
plot(r,p,'ko-');
box on;
grid on;
set(gca,'Fontsize',12);
set(gca,'XTick',[0 .25 .5 .75 1]);
set(gca,'YTick',[0 .25 .5 .75 1]);
set(gca,'XGrid','on');
set(gca,'YGrid','on');
xlabel('Recall');
ylabel('Precision');
title(ti);
axis square;
axis([0 1 0 1]);


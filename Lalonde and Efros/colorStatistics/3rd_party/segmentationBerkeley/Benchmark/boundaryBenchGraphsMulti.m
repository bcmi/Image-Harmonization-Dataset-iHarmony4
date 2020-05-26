function boundaryBenchGraphsMulti(baseDir)
% function boundaryBenchGraphsMulti(baseDir)
%
% See also boundaryBenchGraphs.
%
% David Martin <dmartin@eecs.berkeley.edu>
% July 2003

presentations = {'gray','color'};
presNames = {'Grayscale','Color'};
iidsTest = imgList('test');

% Infer list of algorithms from directories present.
for k = 1:length(presentations),
  pres = presentations{k};
  dirlist = dir(fullfile(baseDir,pres));
  algs{k} = {};
  for i = 1:length(dirlist),
    alg = dirlist(i).name;
    if alg(1)=='.', continue; end
    if ~isdir(fullfile(baseDir,pres,alg)), continue; end
    if length(dir(fullfile(baseDir,pres,alg,'name.txt')))~=1, continue; end
    if length(dir(fullfile(baseDir,pres,alg,'score.txt')))~=1, continue; end
    fname = fullfile(baseDir,pres,alg,'scores.txt');
    if length(dir(fname))~=1, continue; end
    tmp = dlmread(fname); % iid,thresh,r,p,f
    if size(tmp,1)~=numel(iidsTest), continue; end
    algs{k}{1+numel(algs{k})} = alg;
  end
end

% Read in all the scores.
for k = 1:length(presentations),
  pres = presentations{k};
  if numel(algs{k})==0, continue; end
  for i = 1:numel(algs{k}),
    alg = algs{k}{i};
    fprintf(2,'Perusing directory %s/%s...\n',pres,alg);
    fname = fullfile(baseDir,pres,alg,'pr.txt');
    prvals{k}{i} = dlmread(fname); % thresh,r,p,f
    fname = fullfile(baseDir,pres,alg,'score.txt');
    ascores{k}{i} = dlmread(fname); % thresh,r,p,f
    fname = fullfile(baseDir,pres,alg,'name.txt');
    fp = fopen(fname,'r');
    names{k}{i} = fgetl(fp);
    fclose(fp);
  end
  fname = fullfile(baseDir,pres,'human','score.txt');
  if numel(dir(fname))>0,
    hscore{k} = dlmread(fname); % r,p,f
  else
    hscore{k} = zeros(3,1);
  end
end

% Sort algorithms by overall F measure.
fprintf(2,'Sorting algorithms...\n');
for k = 1:length(presentations),
  if numel(algs{k})==0, continue; end
  pres = presentations{k};
  f = [];
  for i = 1:numel(algs{k}), f = [f ascores{k}{i}(4)]; end
  [unused,aperm{k}] = sort(f);
  aperm{k} = aperm{k}(end:-1:1);
end

fprintf(2,'Generating graphs...\n');
for k = 1:length(presentations),
  pres = presentations{k};
  for i = 1:numel(algs{k}),
    for j = i+1:numel(algs{k}),
      ii = aperm{k}(i);
      jj = aperm{k}(j);
      h = figure(1); clf; hold on;
      prplot(h,prvals{k}{ii}(:,2),prvals{k}{ii}(:,3),'ko-');
      prplot(h,prvals{k}{jj}(:,2),prvals{k}{jj}(:,3),'kx-');
      lh = legend(sprintf('F=%4.2f %s',ascores{k}{ii}(4),names{k}{ii}),...
                  sprintf('F=%4.2f %s',ascores{k}{jj}(4),names{k}{jj}),3);
      p = get(lh,'Position');
      p(1) = .225;
      set(lh,'Position',p);
      fname = sprintf('%s_%03d_%03d',pres,i,j);
      print(h,'-depsc2',...
            fullfile(baseDir,'html',sprintf('pr_%s.eps',fname)));
      print(h,'-djpeg95','-r36',...
            fullfile(baseDir,'html',sprintf('pr_%s_half.jpg',fname)));
      print(h,'-djpeg95','-r0',...
            fullfile(baseDir,'html',sprintf('pr_%s_full.jpg',fname)));
      %close(h);
    end
  end
end

function prplot(h,r,p,sym)
figure(h);
plot(r,p,sym);
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


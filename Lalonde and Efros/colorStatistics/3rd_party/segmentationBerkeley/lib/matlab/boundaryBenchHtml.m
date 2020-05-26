function boundaryBenchHtml(baseDir)
% function boundaryBenchHtml(baseDir)
%
% See also boundaryBench, boundaryBenchGraphs.
%
% David Martin <dmartin@eecs.berkeley.edu>
% May 2003

bsdsURL = 'http://www.cs.berkeley.edu/projects/vision/grouping/segbench/BSDS300';
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
    if strcmp(alg,'human'), continue; end
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
  for i = 1:numel(algs{k}),
    alg = algs{k}{i};
    fprintf(2,'Processing directory %s/%s...\n',pres,alg);
    fname = fullfile(baseDir,pres,alg,'scores.txt');
    iscores{k}{i} = dlmread(fname); % iid,thresh,r,p,f
    fname = fullfile(baseDir,pres,alg,'score.txt');
    ascores{k}{i} = dlmread(fname); % thresh,r,p,f
    fname = fullfile(baseDir,pres,alg,'name.txt');
    fp = fopen(fname,'r');
    names{k}{i} = fgetl(fp);
    fclose(fp);
  end

  fname = fullfile(baseDir,pres,'human','scores.txt');
  if numel(dir(fname))>0,
    hiscores{k} = dlmread(fname); % iid,r,p,f
  else 
    hiscores{k} = zeros(10000,4);
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
  pres = presentations{k};
  f = [];
  for i = 1:numel(algs{k}), f = [f ascores{k}{i}(4)]; end
  [unused,aperm{k}] = sort(f);
  aperm{k} = aperm{k}(end:-1:1);
end

% Create algorithms page.
fprintf(2,'Creating algorithms page...\n');
[u1,u2,u3] = mkdir(baseDir,'html');
mainPage = fullfile(baseDir,'html','algorithms.html');
fp = fopen(mainPage,'w');
title = 'Boundary Detection Benchmark: Algorithm Ranking';
fprintf(fp,'<html>\n');
fprintf(fp,'<head>\n');
fprintf(fp,'<title>%s</title>\n',title);
fprintf(fp,'</head>\n');
fprintf(fp,'<body>\n');
fprintf(fp,'<p><a href="main.html">Go to Main Page.</a>\n');
fprintf(fp,'<p><a href="images.html">Go to Image Ranking</a>.\n');
fprintf(fp,'<h2>%s</h2>\n',title);
fprintf(fp,'<h3>Summary Tables</h3>\n',presNames{k});
fprintf(fp,'<p><table cellpadding=5 border=0>\n');
fprintf(fp,'<tr>\n');
for k = 1:length(presentations),
  pres = presentations{k};
  fprintf(fp,'<th>%s</th>\n',presNames{k});
end
fprintf(fp,'</tr>\n');
fprintf(fp,'<tr valign=top>\n');
for k = 1:length(presentations),
  fprintf(fp,'<td>\n');
  pres = presentations{k};
  fprintf(fp,'<p><table cellpadding=5 border=1>\n');
  fprintf(fp,'<tr><th>Rank</th><th>Score</th><th>Algorithm</th></tr>\n');
  fprintf(fp,'<tr>\n');
  fprintf(fp,'<td align=center>0</td>\n');
  fprintf(fp,'<td align=center>%4.2f</td>\n',hscore{k}(3));
  fprintf(fp,'<td align=left>Humans</td>\n');
  fprintf(fp,'</tr>\n');
  for i = 1:numel(algs{k}),
    alg = algs{k}{aperm{k}(i)};
    name = names{k}{aperm{k}(i)};
    score = ascores{k}{aperm{k}(i)}(4);
    fprintf(fp,'<tr>\n');
    fprintf(fp,'<td align=center>%d</td>\n',i);
    fprintf(fp,'<td align=center>%4.2f</td>\n',score);
    fprintf(fp,'<td align=left><a href="../%s/%s/main.html">%s</a></td>\n',pres,alg,name);
    fprintf(fp,'</tr>\n');
  end
  fprintf(fp,'</table>\n');
  fprintf(fp,'</td>\n');
end
fprintf(fp,'</tr>\n');
fprintf(fp,'</table>\n');
fprintf(fp,'<h3>Comparison Graphs</h3>\n',presNames{k});
fprintf(fp,'<p><table cellpadding=5 border=1>\n');
fprintf(fp,'<tr>\n');
for k = 1:length(presentations),
  pres = presentations{k};
  fprintf(fp,'<th>%s</th>\n',presNames{k});
end
fprintf(fp,'</tr>\n');
fprintf(fp,'<tr valign=top>\n');
for k = 1:length(presentations),
  fprintf(fp,'<td width=500>\n');
  fprintf(fp,'<ul>\n');
  pres = presentations{k};
  for i = 1:numel(algs{k}),
    for j = i+1:numel(algs{k}),
      ii = aperm{k}(i);
      jj = aperm{k}(j);
      fprintf(fp,'<li><a href="pr_%s_%03d_%03d_full.jpg">%s vs. %s</a>\n',pres,i,j,names{k}{ii},names{k}{jj});
    end
  end
  fprintf(fp,'</ul>\n');
  fprintf(fp,'</td>\n');
end
fprintf(fp,'</tr>\n');
fprintf(fp,'</table>\n');
fprintf(fp,'<h3>Detail Tables</h3>\n',presNames{k});
for k = 1:length(presentations),
  pres = presentations{k};
  fprintf(fp,'<h4>%s</h4>\n',presNames{k});
  fprintf(fp,'<p><table cellpadding=5 border=1>\n');
  fprintf(fp,'<tr><th>Rank</th><th>Score</th><th>Algorithm</th><th>PR Curve</th></tr>\n');
  fprintf(fp,'<tr>\n');
  fprintf(fp,'<td align=center>0</td>\n');
  fprintf(fp,'<td align=center>%4.2f</td>\n',hscore{k}(3));
  fprintf(fp,'<td align=left>Humans</td>\n');
  fprintf(fp,'<td align=center><img src="../%s/human/pr_full.jpg"></td>\n',pres);
  fprintf(fp,'</tr>\n');
  for i = 1:numel(algs{k}),
    alg = algs{k}{aperm{k}(i)};
    name = names{k}{aperm{k}(i)};
    score = ascores{k}{aperm{k}(i)}(4);
    fprintf(fp,'<tr>\n');
    fprintf(fp,'<td align=center>%d</td>\n',i);
    fprintf(fp,'<td align=center>%4.2f</td>\n',score);
    fprintf(fp,'<td width=200 align=left><a href="../%s/%s/main.html">%s</a></td>\n',pres,alg,name);
    fprintf(fp,'<td align=center><img src="../%s/%s/pr_full.jpg"></td>\n',pres,alg);
    fprintf(fp,'</tr>\n');
  end
  fprintf(fp,'</table>\n');
end
fprintf(fp,'<p>Page generated on %s.\n',datestr(now));
fprintf(fp,'</body>\n');
fprintf(fp,'</html>\n');
fclose(fp);

% Create algorithm pages.
for k = 1:length(presentations),
  pres = presentations{k};
  for i = 1:numel(algs{k}),
    alg = algs{k}{i};
    fprintf(2,'Creating page for ''%s''...\n',alg);
    fname = fullfile(baseDir,pres,alg,'main.html');
    fp = fopen(fname,'w');
    title = sprintf('[%s] Boundary Detection Benchmark: Algorithm "%s"',presNames{k},names{k}{i});
    fprintf(fp,'<html>\n');
    fprintf(fp,'<head>\n');
    fprintf(fp,'<title>%s</title>\n',title);
    fprintf(fp,'</head>\n');
    fprintf(fp,'<body>\n');
    fprintf(fp,'<p><a href="../../html/algorithms.html">Back to Algorithm Ranking</a>.\n');
    fprintf(fp,'<h2>%s</h2>\n',title);
    fname2 = fullfile(baseDir,pres,alg,'about.html');
    if length(dir(fname2))==1,
      fprintf(fp,'<p>\n');
      fp2 = fopen(fname2,'r');
      fwrite(fp,char(fread(fp2)'));
      fclose(fp2);
    end
    fprintf(fp,'<p><img src="pr_full.jpg">\n');
    fprintf(fp,'<p>Click on an image for additional details.\n');
    %fprintf(fp,'<h4>Test Images</h4>\n');
    fprintf(fp,'<p><table border=0>\n');
    nper = 5;
    for j = 1:numel(iidsTest),
      iid = iidsTest(j);
      score = iscores{k}{i}(j,5);
      if iid~=iscores{k}{i}(j,1), error('bug'); end
      if mod(j,nper)==1, fprintf(fp,'<tr>\n'); end
      fprintf(fp,'<td>\n');
      fprintf(fp,'<table border=0 cellpadding=0><tr><td>\n');
      fprintf(fp,'#%d (%d) F=%4.2f <br> ',j,iid,score);
      %fprintf(fp,'#%d (%d) <br>\n',j,iid);
      fprintf(fp,'<a href="%d.html">\n',iid);
      fprintf(fp,'<img border=0 src="%s/html/images/plain/quarter/%s/%d.jpg">\n',bsdsURL,pres,iid);
      fprintf(fp,'</a>\n');
      fprintf(fp,'</td></tr></table>\n');
      fprintf(fp,'</td>\n');
      if mod(j,nper)==0 | j==numel(iidsTest), fprintf(fp,'</tr>\n'); end
    end
    fprintf(fp,'</table>\n');
    fprintf(fp,'<p>Page generated on %s.\n',datestr(now));
    fprintf(fp,'</body>\n');
    fprintf(fp,'</html>\n');
    fclose(fp);
    % Create image pages for this algorithm.
    for j = 1:numel(iidsTest),
      iid = iidsTest(j);
      score = iscores{k}{i}(j,5);
      fname = fullfile(baseDir,pres,alg,sprintf('%d.html',iid));
      fp = fopen(fname,'w');
      title = sprintf(...
          '[%s] Boundary Detection Benchmark: Algorithm "%s" Image #%d (%d)',presNames{k},names{k}{i},j,iid);
      fprintf(fp,'<html>\n');
      fprintf(fp,'<head>\n');
      fprintf(fp,'<title>%s</title>\n',title);
      fprintf(fp,'</head>\n');
      fprintf(fp,'<body>\n');
      fprintf(fp,'<p><a href="main.html">Back to Algorithm "%s" page</a>.\n',names{k}{i});
      fprintf(fp,'<h2>%s</h2>\n',title);
      %fprintf(fp,'<p>F=%4.2f',score);
      fprintf(fp,'<p><img src="%s/html/images/plain/normal/%s/%d.jpg">\n',bsdsURL,pres,iid);
      fprintf(fp,'<table border=0>\n');
      fprintf(fp,'<tr>\n');
      fprintf(fp,'<tr><td align=center><b>Machine</b><br><img src="%d.bmp"></td>>\n',iid);
      fprintf(fp,'<td><img src="%d_pr_full.jpg"></td>\n',iid);
      fprintf(fp,'</tr>\n');
      fprintf(fp,'<tr>\n');
      fprintf(fp,'<tr><td align=center><b>Human</b><br><img src="../human/%d.bmp"></td>>\n',iid);
      fprintf(fp,'<td><img src="../human/%d_pr_full.jpg"></td>\n',iid);
      fprintf(fp,'</tr>\n');
      fprintf(fp,'</table>\n');
      fprintf(fp,'<p>Page generated on %s.\n',datestr(now));
      fprintf(fp,'</body>\n');
      fprintf(fp,'</html>\n');
      fclose(fp);
    end
  end
end

% Sort the images by best F measure across all algorithms.
% Remember which algorithm had the best score for each image.
fprintf(2,'Sorting images...\n');
for k = 1:length(presentations),
  if numel(algs{k})==0, continue; end
  bestf{k} = zeros(numel(iidsTest),1);
  bestalg{k} = zeros(numel(iidsTest),1);
  for j = 1:numel(iidsTest),
    f = zeros(numel(algs{k}),1);
    for i = 1:numel(algs{k}), f(i) = iscores{k}{i}(j,5); end
    [bestf{k}(j),bestalg{k}(j)] = max(f);
  end
  [unused,iperm{k}] = sort(bestf{k});
  iperm{k} = iperm{k}(end:-1:1);
end

% Create images page.
fprintf(2,'Creating images page...\n');
mainPage = fullfile(baseDir,'html','images.html');
fp = fopen(mainPage,'w');
title = 'Boundary Detection Benchmark: Image Ranking';
fprintf(fp,'<html>\n');
fprintf(fp,'<head>\n');
fprintf(fp,'<title>%s</title>\n',title);
fprintf(fp,'</head>\n');
fprintf(fp,'<body>\n');
fprintf(fp,'<p><a href="main.html">Go to Main Page</a>.\n');
fprintf(fp,'<p><a href="algorithms.html">Go to Algorithm Ranking</a>.\n');
fprintf(fp,'<h2>%s</h2>\n',title);
fprintf(fp,'<p>Click on an image for additional details.\n');
fprintf(fp,'<p><table border=1>\n');
fprintf(fp,'<tr><th></th>\n');
for k = 1:length(presentations),
  fprintf(fp,'<th colspan=3>%s</th>\n',presNames{k});
end
fprintf(fp,'</tr>\n');
fprintf(fp,'<tr><th>Rank</th>\n');
for k = 1:length(presentations),
  fprintf(fp,'<th>ID</th><th>Image</th><th>Best Algorithm [Score]</th>\n');
end
fprintf(fp,'</tr>\n');

for j = 1:numel(iidsTest),
  fprintf(fp,'<tr>\n');
  fprintf(fp,'<td align=center><b>%d</b></td>\n',j);
  for k = 1:length(presentations),
    if numel(algs{k})==0, 
      fprintf(fp,'<td></td>\n');
      fprintf(fp,'<td></td>\n');
      fprintf(fp,'<td></td>\n');
      continue; 
    end
    pres = presentations{k};
    iid = iidsTest(iperm{k}(j));
    f = bestf{k}(iperm{k}(j));
    maxf = hiscores{k}(iperm{k}(j),4);
    alg = algs{k}{bestalg{k}(iperm{k}(j))};
    name = names{k}{bestalg{k}(iperm{k}(j))};
    fprintf(fp,'<td align=center>#%d (%d)</td>\n',iperm{k}(j),iid);
    fprintf(fp,'<td align=center>\n');
    fprintf(fp,'<a href="%d-%s.html">\n',iid,pres);
    fprintf(fp,'<img border=0 src="%s/html/images/plain/quarter/%s/%d.jpg">\n',bsdsURL,pres,iid);
    fprintf(fp,'</a>\n');
    fprintf(fp,'</td>\n');
    fprintf(fp,'<td align=left><a href="../%s/%s/main.html">%s</a><br>[ %4.2f / %4.2f ]</td>\n',pres,alg,name,f,maxf);
  end
  fprintf(fp,'</tr>\n');
end
fprintf(fp,'</table>\n');
fprintf(fp,'<p>Page generated on %s.\n',datestr(now));
fprintf(fp,'</body>\n');
fprintf(fp,'</html>\n');
fclose(fp);

% Create image pages.
for j = 1:numel(iidsTest),
  iid = iidsTest(j);
  fprintf(2,'Creating pages for image #%d (%d)...\n',j,iid);
  for k = 1:length(presentations),
    if numel(algs{k})==0, continue; end
    pres = presentations{k};
    fname = fullfile(baseDir,'html',sprintf('%d-%s.html',iid,pres));
    fp = fopen(fname,'w');
    title = sprintf('[%s] Boundary Detection Benchmark: Image #%d (%d) Rank=%d',presNames{k},j,iid,find(iperm{k}==j));
    fprintf(fp,'<html>\n');
    fprintf(fp,'<head>\n');
    fprintf(fp,'<title>%s</title>\n',title);
    fprintf(fp,'</head>\n');
    fprintf(fp,'<body>\n');
    fprintf(fp,'<p><a href="images.html">Back to Image Ranking</a>.\n');
    fprintf(fp,'<p><a href="%d-%s.html"">Go to %s page</a>.\n',iid,presentations{3-k},presNames{3-k});
    fprintf(fp,'<h2>%s</h2>\n',title);

    f = zeros(numel(algs{k}),1);
    for i = 1:numel(algs{k}), f(i) = iscores{k}{i}(j,5); end
    [unused,perm] = sort(f);
    perm = perm(end:-1:1);

    fprintf(fp,'<p><table cellpadding=5 border=1>\n');
    fprintf(fp,'<tr><th>Rank</th><th>Score</th><th>Algorithm</th>\n');
    fprintf(fp,'<tr>\n');
    fprintf(fp,'<td align=center>0</td>\n');
    fprintf(fp,'<td align=center>%4.2f</td>\n',hiscores{k}(j,4));
    fprintf(fp,'<td align=left>Humans</td>\n');
    fprintf(fp,'</tr>\n');
    for i = 1:numel(algs{k}),
      fprintf(fp,'<tr>\n');
      fprintf(fp,'<td align=center>%d</td>\n',i);
      fprintf(fp,'<td align=center>%4.2f</td>\n',f(perm(i)));
      fprintf(fp,'<td align=left>%s</td>\n',names{k}{perm(i)});
      fprintf(fp,'</tr>\n');
    end
    fprintf(fp,'</table>\n');

    fprintf(fp,'<p>\n');
    fprintf(fp,'<img src="%s/html/images/plain/normal/%s/%d.jpg">\n',bsdsURL,pres,iid);
    fprintf(fp,'<img src="../%s/human/%d.bmp">\n',pres,iid);
    
    fprintf(fp,'<p><table border=1>\n');
    fprintf(fp,'<tr><th width=50>Rank Algorithm (Score)</th><th>Pb</th><th>Precision/Recall</th></tr>\n');
    fprintf(fp,'<tr>\n');
    fprintf(fp,'<td align=center><b>0</b><br>Humans<br>(%4.2f)</td>\n',hiscores{k}(j,4));
  fprintf(fp,'<td align=center><img src="../%s/human/%d.bmp"></td>\n',pres,iid);
  fprintf(fp,'<td align=center><img src="../%s/human/%d_pr_full.jpg"></td>\n',pres,iid);
  fprintf(fp,'</tr>\n');
    for i = 1:numel(algs{k}),
      fprintf(fp,'<tr>\n');
      fprintf(fp,'<td align=center width=50><b>%d</b><br>%s<br>(%4.2f)</td>\n',i,names{k}{perm(i)},f(perm(i)));
      fprintf(fp,'<td align=center><img src="../%s/%s/%d.bmp"></td>\n',pres,algs{k}{perm(i)},iid);
      fprintf(fp,'<td align=center><img src="../%s/%s/%d_pr_full.jpg"></td>\n',pres,algs{k}{perm(i)},iid);
      fprintf(fp,'</tr>\n');
    end
    fprintf(fp,'</table>\n');
    
    fprintf(fp,'<p>Page generated on %s.\n',datestr(now));
    fprintf(fp,'</body>\n');
    fprintf(fp,'</html>\n');
    fclose(fp);
  end
end

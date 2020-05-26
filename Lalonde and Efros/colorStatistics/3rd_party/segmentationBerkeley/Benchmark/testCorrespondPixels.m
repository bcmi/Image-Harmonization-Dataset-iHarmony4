
for n = round(logspace(0,2,10)),
  for thresh = linspace(0,1,10),
    disp(sprintf('n=%d thresh=%g\n',n,thresh));
    bmap1 = double(rand(n)>thresh);
    bmap2 = double(rand(n)>thresh);
    maxDist = 0.05;
    tic;
    [match1,match2,cost,oc] = correspondPixels(bmap1,bmap2,maxDist);
    t=toc;
    disp(sprintf('%g sec\n',t));
    npix = length(find(bmap1)) + length(find(bmap2));
    ncor = length(find(match1)) + length(find(match2));
    nout = length(find(bmap1&~match1)) + length(find(bmap2&~match2));
    disp([ npix ncor nout ]);
    if ncor+nout ~= npix, error('bug'); end
    a = [find(match1) match1(find(match1))]; 
    b = sortrows([match2(find(match2)) find(match2)]);
    if sum(sum(a-b)) ~= 0, error('bug'); end
  end
end

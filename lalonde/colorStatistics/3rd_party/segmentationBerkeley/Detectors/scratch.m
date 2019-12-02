
for h = 0.1:0.2:0.9,
  indir = 'pb/bgtg_0.01_0.02_64';
  outdir = sprintf('pb/bgtg_hys_%g',h);
  fprintf('%s --> %s...\n',indir,outdir);
  dohyst(indir,outdir,h);
end

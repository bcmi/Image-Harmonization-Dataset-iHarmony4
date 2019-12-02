
for h = 0.1:0.2:0.9,
  f = sprintf('../Detectors/pb/bgtg_hys_%g',h);
  fprintf('%s...\n',f);
  boundaryBench(f,30,true);
end

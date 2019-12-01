
no = 6;
ss = 1;
ns = 2;
sc = sqrt(2);
el = 2;
fb = fbCreate(no,ss,ns,sc,el);
for k = [32 64 128],
  tex = unitex(fb,k);
  tsim = textonsim(fb,tex);
  [tim,tperm] = visTextons(tex,fb);
  save(sprintf('unitex_%.2g_%.2g_%.2g_%.2g_%.2g_%d.mat',...
               no,ss,ns,sc,el,k),...
       'fb','tex','tsim','tim','tperm');
end


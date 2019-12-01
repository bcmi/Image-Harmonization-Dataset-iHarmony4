function evalCGTG(pres)

iids = imgList('test');

dirname = fullfile('pb',pres,'cgtg');
ignore = mkdir(dirname);
for i = 1:numel(iids),
  iid = iids(i);
  fprintf(2,'Computing Pb for image %d/%d (iid=%d) using %s (%s)...\n',...
          i,numel(iids),iid,'CG/TG',pres);
  pb = pbCGTG(imgRead(iid));
  imwrite(pb,fullfile(dirname,sprintf('%d.bmp',iid)),'bmp');
end

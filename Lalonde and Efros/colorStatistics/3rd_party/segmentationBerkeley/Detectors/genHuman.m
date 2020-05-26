function genHuman()

iids = imgList('test');
presentations = {'gray','color'};

for j = 1:numel(presentations),
  pres = presentations{j};
  dirname = fullfile('pb',pres,'human');
  ignore = mkdir(dirname);
  for i = 1:numel(iids),
    iid = iids(i);
    pb = pbHuman(pres,iid);
    imwrite(pb,fullfile(dirname,sprintf('%d.bmp',iid)),'bmp');
  end
end

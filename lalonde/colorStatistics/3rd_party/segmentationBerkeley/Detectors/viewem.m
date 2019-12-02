
iids = imgList('test');

for i = 1:numel(iids),
  iid = iids(i);
  im = imgRead(iid);
  figure(2); subplot(2,2,1); imshow(im);
  title(sprintf('%d/%d (iid=%d)',i,numel(iids),iid));
  
  pb = double(imread(sprintf('pb/gm_2_4/%d.bmp',iid)))/255;
  figure(2); subplot(2,2,2); imagesc(pb,[0 1]); axis image; axis off;
  title('BG(2,4)');
  
  pb = double(imread(sprintf('pb/bgtg_0.01_0.02_64/%d.bmp',iid)))/255;
  figure(2); subplot(2,2,3); imagesc(pb,[0 1]); axis image; axis off;
  title('BGTG');

  pb = double(imread(sprintf('pb/cgtg/%d.bmp',iid)))/255;
  figure(2); subplot(2,2,4); imagesc(pb,[0 1]); axis image; axis off;
  title('CGTG');

  pause;
end

% generate Pb images for a variety of detectors

iids = imgList('test');
presentations = {'gray','color'};

ignore = mkdir('pb');
for j = 1:numel(presentations),
  pres = presentations{j};
  ignore = mkdir(fullfile('pb',pres));
end

ignore = mkdir('pb/random');
for iid = iids,
  im = rgb2gray(imgRead(iid));
  fprintf(2,'Computing Pb for image %d using random...\n',iid);
  pb = pbRandom(im);
  imwrite(pb,sprintf('pb/random/%d.bmp',iid),'bmp');
end

for sigma = [1 2 4 8 16],
  ignore = mkdir(sprintf('pb/gm_%d',sigma));
  for iid = iids,
    im = rgb2gray(imgRead(iid));
    fprintf(2,'Computing Pb for image %d using gm (sigma=%d)...\n',iid,sigma);
    pb = pbGM(im,sigma);
    imwrite(pb,sprintf('pb/gm_%d/%d.bmp',sigma,iid),'bmp');
  end
end

for sigma = [1 2 4 8 16],
  ignore = mkdir(sprintf('pb/2mm_%d',sigma));
  for iid = iids,
    im = rgb2gray(imgRead(iid));
    fprintf(2,'Computing Pb for image %d using 2mm (sigma=%d)...\n',iid,sigma);
    pb = pb2MM(im,sigma);
    imwrite(pb,sprintf('pb/2mm_%d/%d.bmp',sigma,iid),'bmp');
  end
end

for sigma = [1 2 4],
  ignore = mkdir(sprintf('pb/gm_%d_%d',sigma,2*sigma));
  for iid = iids,
    im = rgb2gray(imgRead(iid));
    fprintf(2,'Computing Pb for image %d using multiscale gm...\n',iid);
    pb = pbGM2(im,sigma);
    imwrite(pb,sprintf('pb/gm_%d_%d/%d.bmp',sigma,2*sigma,iid),'bmp');
  end
end

for sigma = [1 2],
  ignore = mkdir(sprintf('pb/2mm_%d_%d',sigma,2*sigma));
  for iid = iids,
    im = rgb2gray(imgRead(iid));
    fprintf(2,'Computing Pb for image %d using multiscale 2MM...\n',iid);
    pb = pb2MM2(im,sigma);
    imwrite(pb,sprintf('pb/2mm_%d_%d/%d.bmp',sigma,2*sigma,iid),'bmp');
  end
end

for sigma = [2 4],
  ignore = mkdir(sprintf('pb/canny_%d',sigma));
  for iid = iids,
    im = rgb2gray(imgRead(iid));
    fprintf(2,'Computing Pb for image %d using canny...\n',iid);
    pb = pbCanny(im,sigma);
    imwrite(pb,sprintf('pb/canny_%d/%d.bmp',sigma,iid),'bmp');
  end
end

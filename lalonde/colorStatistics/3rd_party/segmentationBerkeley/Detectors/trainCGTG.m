function trainCGTG(pres)

% get features and labels
[f,y] = sampleDetector(@detector,pres);
f=f'; y=y';
% normalize features to unit variance
fstd = std(f);
fstd = fstd + (fstd==0);
f = f ./ repmat(fstd,size(f,1),1);
% fit the model
fprintf(2,'Fitting model...\n');
beta = logist2(y,f);
% save the result
save(sprintf('beta_cgtg_%s.txt',pres),'fstd','beta','-ascii');

function [f] = detector(im)
[cg,tg] = detCGTG(im);
l = max(squeeze(cg(:,:,1,:)),[],3);
a = max(squeeze(cg(:,:,2,:)),[],3);
b = max(squeeze(cg(:,:,3,:)),[],3);
t = max(tg,[],3);
l = l(:);
a = a(:);
b = b(:);
t = t(:);
f = [ ones(size(b)) l a b t ]';

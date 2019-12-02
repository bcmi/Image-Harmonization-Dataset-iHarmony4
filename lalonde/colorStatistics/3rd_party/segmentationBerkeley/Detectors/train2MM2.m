function [beta,f,y] = train2MM2()

[f,y] = sampleDetector(@detector1,1000000,8);
fprintf(2,'Fitting model...\n');
save 'samples_2mm_1_2.mat' f y;
beta = logist2(y',f');
save 'beta_2mm_1_2.txt' beta -ascii;

[f,y] = sampleDetector(@detector2,1000000,8);
fprintf(2,'Fitting model...\n');
save 'samples_2mm_2_4.mat' f y;
beta = logist2(y',f');
save 'beta_2mm_2_4.txt' beta -ascii;

function [f] = detector1(im)
f = detector(im,1);

function [f] = detector2(im)
f = detector(im,2);

function [f] = detector(im,sigma)
[a1,b1] = det2MM(im,sigma);
[a2,b2] = det2MM(im,sigma*2);
a1 = sqrt(a1(:)); 
b1 = sqrt(b1(:));
a2 = sqrt(a2(:)); 
b2 = sqrt(b2(:));
f = [ ones(size(a1)) a1 b1 a2 b2 ]';

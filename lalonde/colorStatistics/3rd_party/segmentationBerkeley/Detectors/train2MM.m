function train2MM()

[f,y] = sampleDetector(@detector1,1000000,8);
fprintf(2,'Fitting model...\n');
save 'samples_2mm_1.mat' f y;
beta = logist2(y',f');
save 'beta_2mm_1.txt' beta -ascii;

[f,y] = sampleDetector(@detector2,1000000,8);
fprintf(2,'Fitting model...\n');
save 'samples_2mm_2.mat' f y;
beta = logist2(y',f');
save 'beta_2mm_2.txt' beta -ascii;

[f,y] = sampleDetector(@detector4,1000000,8);
fprintf(2,'Fitting model...\n');
save 'samples_2mm_4.mat' f y;
beta = logist2(y',f');
save 'beta_2mm_4.txt' beta -ascii;

[f,y] = sampleDetector(@detector8,1000000,16);
fprintf(2,'Fitting model...\n');
save 'samples_2mm_8.mat' f y;
beta = logist2(y',f');
save 'beta_2mm_8.txt' beta -ascii;

[f,y] = sampleDetector(@detector16,1000000,32);
fprintf(2,'Fitting model...\n');
save 'samples_2mm_16.mat' f y;
beta = logist2(y',f');
save 'beta_2mm_16.txt' beta -ascii;

function [f] = detector1(im)
f = detector(im,1);

function [f] = detector2(im)
f = detector(im,2);

function [f] = detector4(im)
f = detector(im,4);

function [f] = detector8(im)
f = detector(im,8);

function [f] = detector16(im)
f = detector(im,16);

function [f] = detector(im,sigma)
[a,b] = det2MM(im,sigma);
a = sqrt(a(:)); 
b = sqrt(b(:));
f = [ ones(size(a)) a b ]';


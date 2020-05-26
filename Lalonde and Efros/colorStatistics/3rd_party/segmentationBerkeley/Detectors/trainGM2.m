function [beta,f,y] = trainGM2()

[f,y] = sampleDetector(@detector1,1000000,8);
fprintf(2,'Fitting model...\n');
save 'samples_gm_1_2.mat' f y;
beta = logist2(y',f');
save 'beta_gm_1_2.txt' beta -ascii;

[f,y] = sampleDetector(@detector2,1000000,8);
fprintf(2,'Fitting model...\n');
save 'samples_gm_2_4.mat' f y;
beta = logist2(y',f');
save 'beta_gm_2_4.txt' beta -ascii;

[f,y] = sampleDetector(@detector3,1000000,16);
fprintf(2,'Fitting model...\n');
save 'samples_gm_4_8.mat' f y;
beta = logist2(y',f');
save 'beta_gm_4_8.txt' beta -ascii;

function [f] = detector1(im)
f = detector(im,1);

function [f] = detector2(im)
f = detector(im,2);

function [f] = detector3(im)
f = detector(im,4);

function [f] = detector(im,sigma)
[a] = detGM(im,sigma); 
[b] = detGM(im,sigma*2); 
a = a(:);
b = b(:);
f = [ ones(size(a)) a b ]';


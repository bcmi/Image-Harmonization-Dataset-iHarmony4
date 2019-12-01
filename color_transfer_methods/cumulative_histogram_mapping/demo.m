function demo()
clear; close all;
dbstop if error

I1 = imread('../data/c35030.jpg');
I2 = imread('../data/c172513.jpg');
M1 = imread('../data/c35030_434421.jpg');
M2 = imread('../data/c172513_1275867.jpg');

M1(M1<255)=0; 
M2(M2<255)=0; 
M1 = M1 / 255; 
M2 = M2 / 255;

new_im1 = perform_cumulative_histogram_mapping(I1, I2, M1>0, M2>0);

imwrite(new_im1, '../data/c35030_hgm.jpg');
        

function new_im_tgt = transform_image(im_tgt, im_src, mask_tgt, mask_src)

% transform im_tgt using the mean and covariance mattrix of im_src and
% im_tgt. im_src is N1x3 matrix and im_tgt is N2x3 matrix.
%
% Ref: Xuezhong Xiaoand Lizhuang Ma. "Color Transfer in Correlated Color
%      Space". VRCIA'06.
%
% Wei Xu
% August 2009

valid_tgt = im_tgt(mask_tgt>0,:);
valid_src = im_src(mask_src>0,:);

% mean and covariance matrix computation
mean_src = mean(valid_src);
cov_src = cov(valid_src);
mean_tgt = mean(valid_tgt);
cov_tgt = cov(valid_tgt);

% SVD decomposition
[U1_1, S1_1, V1_1] = svd(cov_src);
[U2_1, S2_1, V2_1] = svd(cov_tgt);

% eigen decomposition
[U1,S1] = eig(cov_src); 
[U2,S2] = eig(cov_tgt);
S1 = diag(S1);  %column
S2 = diag(S2);

% compose the transformation matrix
T_src = [1 0 0 mean_src(1); 0 1 0 mean_src(2); 0 0 1 mean_src(3); 0 0 0 1];
T_tgt = [1 0 0 -mean_tgt(1); 0 1 0 -mean_tgt(2); 0 0 1 -mean_tgt(3); 0 0 0 1];
R_src = [U1 [0 0 0]'; 0 0 0 1];
R_tgt = inv([U2 [0 0 0]'; 0 0 0 1]);
% S_src = [S1(1) 0 0 0; 0 S1(2) 0 0; 0 0 S1(3) 0; 0 0 0 1]; % not good
% S_tgt= [1/S2(1) 0 0 0; 0 1/S2(2) 0 0; 0 0 1/S2(3) 0; 0 0 0 1];
S_src = [sqrt(S1(1)) 0 0 0; 0 sqrt(S1(2)) 0 0; 0 0 sqrt(S1(3)) 0; 0 0 0 1];
S_tgt = [1/sqrt(S2(1)) 0 0 0; 0 1/sqrt(S2(2)) 0 0; 0 0 1/sqrt(S2(3)) 0; 0 0 0 1];
 
% transform im_tgt
M1 = T_src*R_src*S_src;
M2 = S_tgt*R_tgt*T_tgt;
M = M1*M2;
% tmp = M2*[im_tgt ones(size(im_tgt,1), 1)]';  % for debugging usage
new_im_tgt = M*[im_tgt ones(size(im_tgt,1), 1)]';
new_im_tgt = new_im_tgt(1:3,:)';

% visualization   %comment all code below
% figure, subplot(2,2,1), plot3(im_src(:,1), im_src(:,2), im_src(:,3), 'r.');
% xlabel('R'), ylabel('G'), zlabel('B');
% axis([0 255 0 255 0 255]), grid on, title('source');
% subplot(2,2,2), plot3(im_tgt(:,1), im_tgt(:,2), im_tgt(:,3), 'g.');
% xlabel('R'), ylabel('G'), zlabel('B');
% axis([0 255 0 255 0 255]), grid on, title('target');
% subplot(2,2,3), plot3(new_im_tgt(:,1), new_im_tgt(:,2), new_im_tgt(:,3), 'b.');
% xlabel('R'), ylabel('G'), zlabel('B');
% axis([0 255 0 255 0 255]), grid on, title('converted');


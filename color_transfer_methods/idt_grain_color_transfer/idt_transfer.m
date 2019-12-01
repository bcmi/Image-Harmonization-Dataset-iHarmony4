%
%   colour transfer algorithm based on N-Dimensional PDF Transfer 
%
%   IR = colour_transfer_IDT(I_original, I_target, nb_iterations);
%
%  (c) F. Pitie 2007
%
%  see reference:
%     Automated colour grading using colour distribution transfer. (2007) 
%     Computer Vision and Image Understanding.
%
%  To remove the "grainyness" on the results, you should apply the grain 
%  reducer proposed in the paper and implemented in regrain.m:
%
%  IRR = regrain(I_original, IR);
%
function IR = idt_transfer(I0, I1, M0, M1, nb_iterations)

if (ndims(I0)~=3)
    error('pictures must have 3 dimensions');
end

nb_channels = size(I0,3);

%% reshape images as 3xN matrices
for i=1:nb_channels
    D0(i,:) = reshape(I0(:,:,i), 1, size(I0,1)*size(I0,2));
    D1(i,:) = reshape(I1(:,:,i), 1, size(I1,1)*size(I1,2));
end

mask0 = reshape(double(M0), size(M0,1)*size(M0,2), 1);
mask1 = reshape(double(M1), size(M1,1)*size(M1,2), 1);
V0 = D0(:, mask0>0);
V1 = D1(:, mask1>0);

%% building a sequence of (almost) random projections
% 

R{1} = [1 0 0; 0 1 0; 0 0 1; 2/3 2/3 -1/3; 2/3 -1/3 2/3; -1/3 2/3 2/3];
for i=2:nb_iterations
      R{i} = R{1} * orth(randn(3,3));
end

%for i=2:nb_iterations, R{i} = R{1}; end
%% pdf transfer
DR = D0;
VR = pdf_transfer(V0, V1, R, 1);
DR(:, mask0>0) = VR;

%% reshape the resulting 3xN matrix as an image
IR = I0;
for i=1:nb_channels
    IR(:,:,i) = reshape(DR(i,:), size(IR, 1), size(IR, 2));
end

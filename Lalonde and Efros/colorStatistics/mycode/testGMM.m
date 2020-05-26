function testGMM(type) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup path and load stuff
addpath ../../3rd_party/netlab;
addpath ../../3rd_party/color;
addpath ../histogram;

fn = '/nfs/hn21/projects/labelme/Images/spatial_envelope_256x256_static_8outdoorcategories/tallbuilding_urban989.jpg';
im = imread(fn);
imshow(im);
im = double(im);

% convert to Lab
im = rgb2lab(im);
pixels = reshape(im, 256*256, 3);
pixels = pixels(:, 1:3);
input_dim = size(pixels, 2);

ind = randperm(size(pixels,1));
pixels = pixels(ind(1:10000), :);

nbBins = 128;

% compute ab histogram
% abHisto = myHistoND(pixels, nbBins, [-100 -100], [100 100]);

%% Run EM on the ab dimensions (2-D only)

if type == 1
    t = 'full';
    ncentres = 1:10;
elseif type == 2
    t = 'spherical';
    ncentres = 1:20;
else
    error('Ouaah! I don''t know this option!');
end

errors = zeros(length(ncentres),1);
for c=ncentres(:)'
    fprintf('Using %d gaussians\n', c);

    % Set up mixture model
    mix = gmm(input_dim, c, t);

    % Initialize the model parameters from the data
    options = foptions;
    options(2) = 1e-2;
    options(14) = 20;	% Just use 20 iterations of k-means in initialization
    mix = gmminit(mix, pixels, options);

    % Options for EM
    options = zeros(1, 18);
    options(1) = 1; % quiet
    options(2) = 1e-2;
    options(3) = 1e-2;
    options(14) = 1000;	% Use 1000 iterations for EM

    % Run EM and fit mixtures
    [mix, options, errlog]  = gmmem(mix, pixels, options);
    
    errs = errlog(find(errlog));
    errors(find(ncentres==c)) = errs(end);
end

figure;
plot(ncentres, errors);
[path, name, ext, ver] = fileparts(fn);
title(sprintf('%s covariance gaussians, %s', t, strrep(name, '_', '\_'))), xlabel('Number of gaussians'), ylabel('negative data log-likelihood')
saveas(gcf, sprintf('%s_%s.jpg', name, t));
return;
%% Display results on top of histogram

% figure;
% image(abHisto', 'CDataMapping', 'scaled'); axis xy equal;
figure;
plot(pixels(:,1), pixels(:,2), '.b'); axis equal;
xlabel('a'), ylabel('b');
hold on;

% Display gaussians
for i = 1:ncentres
    if ndims(mix.covars) == 3
        [v,d] = eig(mix.covars(:,:,i));
    elseif ndims(mix.covars) == 2
        [v,d] = eig(eye(2) * mix.covars(i));
    end
    for j = 1:2
        % Ensure that eigenvector has unit length
        v(:,j) = v(:,j)/norm(v(:,j));
        start=mix.centres(i,:)-sqrt(d(j,j))*(v(:,j)');
        endpt=mix.centres(i,:)+sqrt(d(j,j))*(v(:,j)');
        linex = [start(1) endpt(1)];
        liney = [start(2) endpt(2)];
        line(linex, liney, 'Color', 'k', 'LineWidth', 3)
    end
    % Plot ellipses of one standard deviation
    theta = 0:0.02:2*pi;
    x = sqrt(d(1,1))*cos(theta);
    y = sqrt(d(2,2))*sin(theta);
    % Rotate ellipse axes
    ellipse = (v*([x; y]))';
    % Adjust centre
    ellipse = ellipse + ones(length(theta), 1)*mix.centres(i,:);
    plot(ellipse(:,1), ellipse(:,2), 'r-');
end
close all; clc; clear all;

%% Load data
load ('data\\cell_compositing_all.mat');   % load cell_compositing_all

nComp     = length(cell_compositing_all);

for i = 1:nComp
    F(i, :)     = cell_compositing_all{i}{1}(1, :);   % a row is an observation
    B(i, :)     = cell_compositing_all{i}{1}(2, :);
end



%% Visualization
nFeatures = size(F, 2);
cName = {    ... % Luminance
    'lum high', 'lum shdw', 'lum median', ...   %+3  =3
    'lum mean', 'lum std',  'lum skew', 'lum kurt', 'lum entropy', 'lum range', ...                  %+6    9
    'lum portion 01','lum portion 02','lum portion 03','lum portion 04','lum portion 05',  ...
    'lum portion 06','lum portion 07','lum portion 08','lum portion 09','lum portion 10',  ...
    'lum portion 11','lum portion 12','lum portion 13','lum portion 14','lum portion 15',  ...
    'lum portion 16','lum portion 17','lum portion 18','lum portion 19','lum portion 20',   ...     %+20   29
                ... % harsh Lighting
    'harshDrop', 'highPortion', ...     %+2   31
                ... % Local Contrast
    'cntrst top', 'cntrst low', 'cntrst median', ...    %+3   34
    'cntrst mean', 'cntrst std', 'cntrst skew', 'cntrst kurt', 'cntrst entropy', 'cntrst range', ... %+6     40
    'cntrst portion 01','cntrst portion 02','cntrst portion 03','cntrst portion 04','cntrst portion 05',  ...
    'cntrst portion 06','cntrst portion 07','cntrst portion 08','cntrst portion 09','cntrst portion 10',  ...
    'cntrst portion 11','cntrst portion 12','cntrst portion 13','cntrst portion 14','cntrst portion 15',  ...
    'cntrst portion 16','cntrst portion 17','cntrst portion 18','cntrst portion 19','cntrst portion 20',   ...    %+20    60
                ...% Color CCT
    'cct high', 'cct warm', 'cct cold', 'cct median',   ... %+4   64
    'cct mean', 'cct std', 'cct skew', 'cct kurt', 'cct entropy',  'cct range', ...    %+6     70
    'cct portion 01','cct portion 02','cct portion 03','cct portion 04','cct portion 05',  ...
    'cct portion 06','cct portion 07','cct portion 08','cct portion 09','cct portion 10',  ...
    'cct portion 11','cct portion 12','cct portion 13','cct portion 14','cct portion 15',  ...
    'cct portion 16','cct portion 17','cct portion 18','cct portion 19','cct portion 20',   ...    %+20     90
                ...% Color 'sat uration
    'sat top', 'sat low', 'sat median',  ...      %+3     93
    'sat mean', 'sat std', 'sat skew', 'sat kurt', 'sat entropy', 'sat range',  ...   %+6     99
    'sat portion 01','sat portion 02','sat portion 03','sat portion 04','sat portion 05',  ...
    'sat portion 06','sat portion 07','sat portion 08','sat portion 09','sat portion 10',  ...
    'sat portion 11','sat portion 12','sat portion 13','sat portion 14','sat portion 15',  ...
    'sat portion 16','sat portion 17','sat portion 18','sat portion 19','sat portion 20',   ...    %+20        119
                ...% Color 'hue 
    'hue high', 'hue median', ...                   %+2      121
    'hue mean', 'hue std', 'hue skew', 'hue kurt', 'hue entropy', ...        %+5     126
    'hue range 50CW','hue range 30CW','hue range center','hue range 30CCW','hue range 50CCW', ...    %+5    131
    'hue portion 10CW','hue portion 09CW','hue portion 08CW','hue portion 07CW','hue portion 06CW',  ...
    'hue portion 05CW','hue portion 04CW','hue portion 03CW','hue portion 02CW','hue portion 01CW',  ...
    'hue portion 01CCW','hue portion 02CCW','hue portion 03CCW','hue portion 04CCW','hue portion 05CCW',  ...
    'hue portion 06CCW','hue portion 07CCW','hue portion 08CCW','hue portion 09CCW','hue portion 10CCW',   ... %+20  151
        };
    
Ranges = [    ... % Luminance
    11.686, 11.686, 11.686, ...   %+3  =3
    11.686, 11.686,  0, 0, 0, 11.686, ...                  %+6    9
    1.0,    1.0,    1.0,    1.0,    1.0,  ...
    1.0,    1.0,    1.0,    1.0,    1.0,  ...
    1.0,    1.0,    1.0,    1.0,    1.0,  ...
    1.0,    1.0,    1.0,    1.0,    1.0,  ...     %+20   29
                ... % harsh Lighting
    0,  1.0, ...     %+2   31
                ... % Local Contrast
    5, 5, 5, ...    %+3   34
    5, 5, 0, 0, 0, 5, ... %+6     40
    1.0,    1.0,    1.0,    1.0,    1.0,  ...
    1.0,    1.0,    1.0,    1.0,    1.0,  ...
    1.0,    1.0,    1.0,    1.0,    1.0,  ...
    1.0,    1.0,    1.0,    1.0,    1.0,  ...    %+20    60
                ...% Color CCT
    1e6/1500, 1e6/1500, 1e6/1500, 1e6/1500,   ... %+4   64
    1e6/1500, 1e6/1500, 0, 0, 0,  1e6/1500, ...    %+6     70
    1.0,    1.0,    1.0,    1.0,    1.0,  ...
    1.0,    1.0,    1.0,    1.0,    1.0,  ...
    1.0,    1.0,    1.0,    1.0,    1.0,  ...
    1.0,    1.0,    1.0,    1.0,    1.0,  ...    %+20     90
                ...% Color 'sat uration
    11.686, 11.686, 11.686, ...       %+3     93
    11.686, 11.686,  0, 0, 0, 11.686, ...      %+6     99
    1.0,    1.0,    1.0,    1.0,    1.0,  ...
    1.0,    1.0,    1.0,    1.0,    1.0,  ...
    1.0,    1.0,    1.0,    1.0,    1.0,  ...
    1.0,    1.0,    1.0,    1.0,    1.0,  ...    %+20        119
                ...% Color 'hue 
    1, 1, ...                   %+2      121
    1, 1, 0, 0, 0, ...        %+5     126
    1,      1,      1,      1,      1, ...    %+5    131
    1.0,    1.0,    1.0,    1.0,    1.0,  ...
    1.0,    1.0,    1.0,    1.0,    1.0,  ...
    1.0,    1.0,    1.0,    1.0,    1.0,  ...
    1.0,    1.0,    1.0,    1.0,    1.0,  ... %+20  151
        ];

fid = fopen('img\\Features_Stat.txt', 'wt');
      
for i = [ 1,2,3,4,5,6,7,8,9,   ...     % lum
          32,33,34,35,36,37,38,39,40,   ...  % cntrst
          61,62,63,64,65,66,67,68,69,70, ...  % cct
          91,92,93,94,95,96,97,98,99,  ...  % saturation
          120,121,122,123,124,125,126,   ...  % hue
         ]
    f = F(:,i);  % a column vector
    b = B(:,i);  
    
    nanIdx = isnan(f) | isnan(b);
    disp(sprintf('# of NaN in f or b =%d', sum(nanIdx)));
    f(nanIdx) = [];   % remove NaN
    b(nanIdx) = [];
    d = f-b;     
    
    %% Find the robust range of this quantity
    v      = sort( [f', b'], 'descend' );
    num    = length(v);
    if Ranges(i) > 0 
        rng = Ranges(i);
    else 
        rng = max( abs(mean(v(1:floor(0.01*num)))), abs(mean(v(floor(0.99*num):end))) );  %mean(v(1:floor(0.01*num))) - mean(v(floor(0.99*num):end));
    end
    
    mean_f = mean(f);    std_f  = std(f);   stdn_f = std_f / rng; %normalized std
    mean_b = mean(b);    std_b  = std(b);   stdn_b = std_b / rng;
    mean_d = mean(d);    std_d  = std(d);   stdn_d = std_d / rng;
    corrMtrx = corrcoef(f, b);
    corr = corrMtrx(1,2);
    
    entropy(mean_f) = st(sum(isnan(mean_b)));
    
    plot(nrcolr, 'r', linewidth, 2.5);
    
       
    %% PLot fg, bg, and offset
%     h = figure;
%     subplot(1,3,1); 
%     [cnts, xout] = hist(f, 100);
%     h1 = bar(xout, cnts);
%     set(h1, 'facecolor', 'r', 'edgecolor', 'r');
% 
%     
%     subplot(1,3,2);     
%     [cnts, xout] = hist(b, 100);
%     h1 = bar(xout, cnts);
%     set(h1, 'facecolor', 'g', 'edgecolor', 'g');
% 
%     
%     subplot(1,3,3);     
%     [cnts, xout] = hist(d, 100);
%     h1 = bar(xout, cnts);
%     set(h1, 'facecolor', 'b', 'edgecolor', 'b');
% 
%     title(cName{i});
%     
%     saveas(h, sprintf('img\\%s.jpg', cName{i}));
%     %print(h, '-dpdf', '-r300', sprintf('img\\%s.pdf', cName{i}));

    
    %% Only plot delta in vector image
    hh = figure;
    [cnts, xout] = hist(d, 100);
    hh1 = bar(xout, cnts);
    set(hh1,  'facecolor', 'b', 'edgecolor', 'b');
    set(gca, 'xlim', [-rng, rng]);
    set(gca, 'ylim', [0, 1200]);
    set(gca,'FontSize',28);
    set(gca,'LineWidth',3);
    xlabel('Delta = M_f-M_b');
    ylabel('Counts');
    title(cName{i});
    saveTightFigure(hh, sprintf('img\\%s.pdf', cName{i}));

    
    close all;
    
    fprintf(fid, '%s: \n', cName{i});
    fprintf(fid, 'rng = %f \n', rng);
    %fprintf(fid, 'mean_f = %f, std_f = %f, stdn_f = %f\n', mean_f, std_f, stdn_f);
    %fprintf(fid, 'mean_b = %f, std_b = %f, stdn_b = %f\n', mean_b, std_b, stdn_b);
    fprintf(fid, 'mean_d = %f, std_d = %f, stdn_d = %f, corr = %f \n\n', mean_d, std_d, stdn_d, corr);
             
    disp(sprintf('%s\n', cName{i}));
    disp(sprintf('    mean_f = %f, std_f = %f, stdn_f = %f\n', mean_f, std_f, stdn_f));
    disp(sprintf('    mean_b = %f, std_b = %f, stdn_b = %f\n', mean_b, std_b, stdn_b));
    disp(sprintf('    mean_d = %f, std_d = %f, stdn_d = %f, corr = %f \n\n', mean_d, std_d,stdn_d, corr));
    
end

fclose(fid);      




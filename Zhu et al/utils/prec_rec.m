function [prec, tpr, fpr, thresh] = prec_rec(score, target, varargin)
% PREC_REC - Compute and plot precision/recall and ROC curves.
%
%   PREC_REC(SCORE,TARGET), where SCORE and TARGET are equal-sized vectors,
%   and TARGET is binary, plots the corresponding precision-recall graph
%   and the ROC curve.
%
%   Several options of the form PREC_REC(...,'OPTION_NAME', OPTION_VALUE)
%   can be used to modify the default behavior.
%      - 'instanceCount': Usually it is assumed that one line in the input
%                         data corresponds to a single sample. However, it
%                         might be the case that there are a total of N
%                         instances with the same SCORE, out of which
%                         TARGET are classified as positive, and (N -
%                         TARGET) are classified as negative. Instead of
%                         using repeated samples with the same SCORE, we
%                         can summarize these observations by means of this
%                         option. Thus it requires a vector of the same
%                         size as TARGET.
%      - 'numThresh'    : Specify the (maximum) number of score intervals.
%                         Generally, splits are made such that each
%                         interval contains about the same number of sample
%                         lines.
%      - 'holdFigure'   : [0,1] draw into the current figure, instead of
%                         creating a new one.
%      - 'style'        : Style specification for plot command.
%      - 'plotROC'      : [0,1] Explicitly specify if ROC curve should be
%                         plotted.
%      - 'plotPR'       : [0,1] Explicitly specify if precision-recall curve
%                         should be plotted.
%      - 'plotBaseline' : [0,1] Plot a baseline of the random classifier.
%
%   By default, when output arguments are specified, as in
%         [PREC, TPR, FPR, THRESH] = PREC_REC(...),
%   no plot is generated. The arguments are the score thresholds, along
%   with the respective precisions, true-positive, and false-positive
%   rates.
%
%   Example:
%
% x1 = rand(1000, 1);
% y1 = round(x1 + 0.5*(rand(1000,1) - 0.5));
% prec_rec(x1, y1);
% x2 = rand(1000,1);
% y2 = round(x2 + 0.75 * (rand(1000,1)-0.5));
% prec_rec(x2, y2, 'holdFigure', 1);
% legend('baseline','x1/y1','x2/y2','Location','SouthEast');

% Copyright © 9/22/2010 Stefan Schroedl
% Updated     3/16/2010

optargin = size(varargin, 2);
stdargin = nargin - optargin;

if stdargin < 2
    error('at least 2 arguments required');
end

% parse optional arguments
num_thresh = -1;
hold_fig = 0;
plot_roc = (nargout <= 0);
plot_pr  = (nargout <= 0);
instance_count = -1;
style = '';
plot_baseline = 1;

i = 1;
while (i <= optargin)
    if (strcmp(varargin{i}, 'numThresh'))
        if (i >= optargin)
            error('argument required for %s', varargin{i});
        else
            num_thresh = varargin{i+1};
            i = i + 2;
        end
    elseif (strcmp(varargin{i}, 'style'))
        if (i >= optargin)
            error('argument required for %s', varargin{i});
        else
            style = varargin{i+1};
            i = i + 2;
        end
    elseif (strcmp(varargin{i}, 'instanceCount'))
        if (i >= optargin)
            error('argument required for %s', varargin{i});
        else
            instance_count = varargin{i+1};
            i = i + 2;
        end
    elseif (strcmp(varargin{i}, 'holdFigure'))
        if (i >= optargin)
            error('argument required for %s', varargin{i});
        else
            if ~isempty(get(0,'CurrentFigure'))
                hold_fig = varargin{i+1};
            end
            i = i + 2;
        end
    elseif (strcmp(varargin{i}, 'plotROC'))
        if (i >= optargin)
            error('argument required for %s', varargin{i});
        else
            plot_roc = varargin{i+1};
            i = i + 2;
        end
    elseif (strcmp(varargin{i}, 'plotPR'))
        if (i >= optargin)
            error('argument required for %s', varargin{i});
        else
            plot_pr = varargin{i+1};
            i = i + 2;
        end
    elseif (strcmp(varargin{i}, 'plotBaseline'))
        if (i >= optargin)
            error('argument required for %s', varargin{i});
        else
            plot_baseline = varargin{i+1};
            i = i + 2;
        end
    elseif (~ischar(varargin{i}))
        error('only two numeric arguments required');
    else
        error('unknown option: %s', varargin{i});
    end
end

[nx,ny]=size(score);

if (nx~=1 && ny~=1)
    error('first argument must be a vector');
end

[mx,my]=size(target);
if (mx~=1 && my~=1)
    error('second argument must be a vector');
end

score  =  score(:);
target = target(:);

if (length(target) ~= length(score))
    error('score and target must have same length');
end

if (instance_count == -1)
    % set default for total instances
    instance_count = ones(length(score),1);
    target = max(min(target(:),1),0); % ensure binary target
else
    if numel(instance_count)==1
        % scalar
        instance_count = instance_count * ones(length(target), 1);
    end
    [px,py] = size(instance_count);
    if (px~=1 && py~=1)
        error('instance count must be a vector');
    end
    instance_count = instance_count(:);
    if (length(target) ~= length(instance_count))
        error('instance count must have same length as target');
    end
    target = min(instance_count, target);
end

if num_thresh < 0
    % set default for number of thresholds
    score_uniq = unique(score);
    num_thresh = min(length(score_uniq), 100);
end

qvals = (1:(num_thresh-1))/num_thresh;
thresh = [min(score) quantile(score,qvals)];
% remove identical bins
thresh = sort(unique(thresh),2,'descend');
total_target = sum(target);
total_neg = sum(instance_count - target);

prec = zeros(length(thresh),1);
tpr  = zeros(length(thresh),1);
fpr  = zeros(length(thresh),1);
for i = 1:length(thresh)
    idx     = (score >= thresh(i));
    fpr(i)  = sum(instance_count(idx) - target(idx));
    tpr(i)  = sum(target(idx)) / total_target;
    prec(i) = sum(target(idx)) / sum(instance_count(idx));
end
fpr = fpr / total_neg;

if (plot_pr || plot_roc)
    
    % draw
    
    if (~hold_fig)
        figure
        if (plot_pr)
            if (plot_roc)
                subplot(1,2,1);
            end
            
            if (plot_baseline)
                target_ratio = total_target / (total_target + total_neg);
                plot([0 1], [target_ratio target_ratio], 'k');
            end
            
            hold on
            hold all
            
            plot([0; tpr], [1 ; prec], style); % add pseudo point to complete curve
            
            xlabel('recall');
            ylabel('precision');
            title('precision-recall graph');
        end
        if (plot_roc)
            if (plot_pr)
                subplot(1,2,2);
            end
            
            if (plot_baseline)
                plot([0 1], [0 1], 'k');
            end
            
            hold on;
            hold all;
            
            plot([0; fpr], [0; tpr], style); % add pseudo point to complete curve
            
            xlabel('false positive rate');
            ylabel('true positive rate');
            title('roc curve');
            %axis([0 1 0 1]);
            if (plot_roc && plot_pr)
                % double the width
                rect = get(gcf,'pos');
                rect(3) = 2 * rect(3);
                set(gcf,'pos',rect);
            end
        end
        
    else
        if (plot_pr)
            if (plot_roc)
                subplot(1,2,1);
            end
            plot([0; tpr],[1 ; prec], style); % add pseudo point to complete curve
        end
        
        if (plot_roc)
            if (plot_pr)
                subplot(1,2,2);
            end
            plot([0; fpr], [0; tpr], style);
        end
    end
end

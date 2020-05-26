function [pval, k, K] = circ_kuipertest(alpha1, alpha2, res, vis_on)

% [pval, k, K] = circ_kuipertest(sample1, sample2, res, vis_on)
%
%   The Kuiper two-sample test tests whether the two samples differ 
%   significantly.The difference can be in any property, such as mean 
%   location and dispersion. It is a circular analogue of the 
%   Kolmogorov-Smirnov test.  
% 
%   H0: The two distributions are identical.
%   HA: The two distributions are different.
%
% Input: 
%   alpha1    fist sample (in radians)
%   alpha2    second sample (in radians)
%   res       resolution at which the cdf is evaluated
%   vis_on    display graph
%
% Output:
%   pval        p-value; the smallest of .10, .05, .02, .01, .005, .002,
%               .001, for which the test statistic is still higher
%               than the respective critical value. this is due to
%               the use of tabulated values. if p>.1, pval is set to 1.
%   k           test statistic
%   K           critical value
% 
% References:
%   Batschelet, 1980, p. 112
%
% Circular Statistics Toolbox for Matlab

% By Marc J. Velasco and Philipp Berens, 2009
% velasco@ccs.fau.edu


if nargin < 3
    res = 100;
end
if nargin < 4
    vis_on = 0;
end

n = length(alpha1(:));
m = length(alpha2(:));

% create cdfs of both samples
[phis1 cdf1 phiplot1 cdfplot1] = circ_samplecdf(alpha1, res);
[~, cdf2 phiplot2 cdfplot2] = circ_samplecdf(alpha2, res);

% maximal difference between sample cdfs
[dplus, gdpi] = max([0 cdf1-cdf2]);
[dminus, gdmi] = max([0 cdf2-cdf1]);

% calculate k-statistic
k = n * m * (dplus + dminus);

% find p-value
[pval K] = kuiperlookup(min(n,m),k/sqrt(n*m*(n+m)));
K = K * sqrt(n*m*(n+m));


% visualize
if vis_on
    figure 
    plot(phiplot1, cdfplot1, 'b', phiplot2, cdfplot2, 'r');
    hold on
    plot([phis1(gdpi-1), phis1(gdpi-1)], [cdf1(gdpi-1) cdf2(gdpi-1)], 'o:g');
    plot([phis1(gdmi-1), phis1(gdmi-1)], [cdf1(gdmi-1) cdf2(gdmi-1)], 'o:g');
    hold off
    set(gca, 'XLim', [0, 2*pi]);
    set(gca, 'YLim', [0, 1.1]);
    xlabel('Circular Location')
    ylabel('Sample CDF')
    title('CircStat: Kuiper test')
    h = legend('Sample 1', 'Sample 2', 'Location', 'Southeast');
    set(h,'box','off')
    set(gca, 'XTick', pi*(0:.25:2))
    set(gca, 'XTickLabel', {'0', '', '', '', 'pi', '', '', '', '2pi'}) 
end



end

function [p K] = kuiperlookup(n, k)

load kuipertable.mat;
alpha = [.10, .05, .02, .01, .005, .002, .001];
nn = ktable(:,1);  %#ok<NODEF>

% find correct row of the table
[easy row] = ismember(n, nn);
if ~easy
   % find closest value if no entry is present)
   row = length(nn) - sum(n<nn); 
   if row == 0
       error('N too small.');
   else
      warning('N=%d not found in table, using closest N=%d present.',n,nn(row)) %#ok<WNTAG>
   end
end

% find minimal p-value and test-statistic
idx = find(ktable(row,2:end)<k,1,'last');
if ~isempty(idx)
  p = alpha(idx);
else
  p = 1;
end
K = ktable(row,idx+1);

end
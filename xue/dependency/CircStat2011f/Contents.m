% CircStat Toolbox
%   Toolbox for circular statistics with Matlab
%
% Descriptive Statistics.
%   circ_mean     - Mean direction of a sample of circular data
%   circ_median   -	Median direction of a sample of circular data
%   circ_r        - Resultant vector length
%   circ_var      - Circular variance
%   circ_std      - Circular standard deviation
%   circ_moment   - Circular p-th moment 
%   circ_skewness -	Circular skewness
%   circ_kurtosis -	Circular kurtosis
%
% Inferential Statistics.
%  Testing for Circular Uniformity.
%   circ_rtest    - Rayleigh's test for nonuniformity
%   circ_otest    - Hodges-Ajne test (omnibus test) for nonuniformity
%   circ_raotest  - Rao's spacing test for nonuniformity
%   circ_vtest    - V-Test for nonuniformity with known mean direction
%
%  Tests Concerning Mean and Median.
%   circ_confmean - Confidence intervals for mean direction
%   circ_mtest    -	One-sample test for specified mean direction
%   circ_medtest  -	Test for median angle
%   circ_symtest  -	Test for symmetry around median angle
%
%  Paired and Multisample Tests.
%   circ_wwtest   - Two and multi-sample test for equal means; 
%                   one-factor ANOVA
%   circ_hktest   -	Two-factor ANOVA
%   circ_cmtest   - Non-parametric multi-sample test for equal medians
%   circ_ktest    - Test for equal concentration parameter
%   circ_kuipertest - Test for equality of distributions (KS-test)
%
% Measures of Association.
%   circ_corrcc   - Circular-circular correlation coefficient
%   circ_corrcl   -	Circular-linear correlation coefficient
%
% The Von Mises Distribution
%   circ_vmpdf    - Probability density function of the von Mises
%                   distribution
%   circ_vmpar    - Parameter estimation
%   circ_vmrnd    - Random number generation
%
% Others.
%   circ_axial    -	Convert axial data to common scale
%   circ_dist     - Distances around a circle
%   circ_dist2    - Pairwise distances around a circle
%   circ_stats    -	Summary statistics
%   circ_kappa    -	Compute concentration parameter of a VM distribution
%   circ_plot     - Visualization for circular data
%   circ_clust    - Simple clustering
%   circ_rad2ang  - Convert radian to angular values
%   circ_ang2rad  -	Convert angular to radian values
%   circ_samplecdf - Evaluate CDF of a sample
%
% Reference:
%   P. Berens, CircStat: A Matlab Toolbox for Circular Statistics, Journal of Statistical Software,Vol. 31, Issue 10, 2009
%	http://www.jstatsoft.org/v31/i10
%
% Author:
%   Philipp Berens & Marc J. Velasco, 2009


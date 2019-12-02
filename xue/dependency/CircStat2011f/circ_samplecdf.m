function [phis, cdf, phiplot, cdfplot] = circ_samplecdf(thetas, resolution)

% [phis, cdf, phiplot, cdfplot] = circ_samplecdf(thetas, resolution)
%
%   Helper function for circ_kuipertest.
%   Evaluates CDF of sample in thetas.
% 
% Input: 
%   thetas      sample (in radians)
%   resolution  resolution at which the cdf is evaluated
%
% Output:
%   phis        angles at which CDF is evaluated
%   cdf         CDF values at these angles
%   phiplot     as phi, for plotting
%   cdfplot     as cdf, for plotting
% 
%
% Circular Statistics Toolbox for Matlab

% By Marc J. Velasco, 2009
% velasco@ccs.fau.edu

if nargin < 2
    resolution = 100;
end

phis = 0;
cdf = zeros(1, length(phis));

phis = linspace(0,2*pi,resolution+1);
phis = phis(1:end-1);

% ensure all points in thetas are on interval [0, 2pi)
x = thetas(thetas<0);
thetas(thetas<0) = (2*pi-abs(x));

% compute cdf
thetas = sort(thetas); 
dprob = 1/length(thetas); %incremental change in probability
cumprob = 0; %cumultive probability so far

% for a little bit, we'll add on 2pi to the end of phis
phis = [phis 2*pi];

for j=1:resolution
    minang = phis(j);
    maxang = phis(j+1);
    currcount = sum(thetas >= minang & thetas < maxang);
    cdf(j) = cumprob + dprob*currcount;
    cumprob = cdf(j);
end

phis = phis(1:end-1);

% for each point in x, duplicate it with the preceding value in y
phis2 = phis;
cdf2 = [0 cdf(1:end-1)];

cdfplottable = [];
phisplottable = [];

for j=1:length(phis);
   phisplottable = [phisplottable phis(j) phis2(j)]; %#ok<AGROW>
   cdfplottable = [cdfplottable cdf2(j) cdf(j)]; %#ok<AGROW>
end

phiplot = [phisplottable 2*pi];
cdfplot = [cdfplottable 1];






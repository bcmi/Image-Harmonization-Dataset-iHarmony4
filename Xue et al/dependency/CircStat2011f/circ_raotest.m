function [p U UC] = circ_raotest(alpha)

% [p U UC] = circ_raotest(alpha)
%   Calculates Rao's spacing test by comparing distances between points on
%   a circle to those expected from a uniform distribution.
%
%   H0: Data is distributed uniformly around the circle. 
%   H1: Data is not uniformly distributed around the circle.
%
%   Alternative to the Rayleigh test and the Omnibus test. Less powerful
%   than the Rayleigh test when the distribution is unimodal on a global
%   scale but uniform locally.
%
%   Due to the complexity of the distributioin of the test statistic, we
%   resort to the tables published by 
%       Russell, Gerald S. and Levitin, Daniel J.(1995)
%       'An expanded table of probability values for rao's spacing test'
%       Communications in Statistics - Simulation and Computation
%   Therefore the reported p-value is the smallest alpha level at which the
%   test would still be significant. If the test is not significant at the
%   alpha=0.1 level, we return the critical value for alpha = 0.05 and p =
%   0.5.
%
%   Input:
%     alpha     sample of angles
%
%   Output:
%     p         smallest p-value at which test would be significant
%     U         computed value of the test-statistic u
%     UC        critical value of the test statistic at sig-level
%
%
%   References:
%     Batschelet, 1981, Sec 4.6
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de

alpha = alpha(:);

% for the purpose of the test, convert to angles
alpha = circ_rad2ang(alpha);
n = length(alpha);
alpha = sort(alpha);

% compute test statistic
U = 0;
lambda = 360/n;
for j = 1:n-1
    ti = alpha(j+1) - alpha(j);
    U = U + abs(ti - lambda);
end

tn = (360 - alpha(n) + alpha(1));
U = U + abs(tn-lambda);

U = (1/2)*U;

% get critical value from table
[p UC] = getVal(n,U);



function [p UC] = getVal(N, U)

% Table II from Russel and Levitin, 1995

alpha = [0.001, .01, .05, .10];
table = [ 4   247.32, 221.14, 186.45, 168.02;
          5   245.19, 211.93, 183.44, 168.66;
          6   236.81, 206.79, 180.65, 166.30;
          7   229.46, 202.55, 177.83, 165.05;
          8   224.41, 198.46, 175.68, 163.56;
          9   219.52, 195.27, 173.68, 162.36;
          10  215.44, 192.37, 171.98, 161.23;
          11  211.87, 189.88, 170.45, 160.24;
          12  208.69, 187.66, 169.09, 159.33;
          13  205.87, 185.68, 167.87, 158.50;
          14  203.33, 183.90, 166.76, 157.75;
          15  201.04, 182.28, 165.75, 157.06;
          16  198.96, 180.81, 164.83, 156.43;
          17  197.05, 179.46, 163.98, 155.84;
          18  195.29, 178.22, 163.20, 155.29;
          19  193.67, 177.08, 162.47, 154.78;
          20  192.17, 176.01, 161.79, 154.31;
          21  190.78, 175.02, 161.16, 153.86;
          22  189.47, 174.10, 160.56, 153.44;
          23  188.25, 173.23, 160.01, 153.05;
          24  187.11, 172.41, 159.48, 152.68;
          25  186.03, 171.64, 158.99, 152.32;
          26  185.01, 170.92, 158.52, 151.99;
          27  184.05, 170.23, 158.07, 151.67;
          28  183.14, 169.58, 157.65, 151.37;
          29  182.28, 168.96, 157.25, 151.08;
          30  181.45, 168.38, 156.87, 150.80;
          35  177.88, 165.81, 155.19, 149.59;
          40  174.99, 163.73, 153.82, 148.60;
          45  172.58, 162.00, 152.68, 147.76;
          50  170.54, 160.53, 151.70, 147.05;
          75  163.60, 155.49, 148.34, 144.56;
          100 159.45, 152.46, 146.29, 143.03;
          150 154.51, 148.84, 143.83, 141.18;
          200 151.56, 146.67, 142.35, 140.06;
          300 148.06, 144.09, 140.57, 138.71;
          400 145.96, 142.54, 139.50, 137.89;
          500 144.54, 141.48, 138.77, 137.33;
          600 143.48, 140.70, 138.23, 136.91;
          700 142.66, 140.09, 137.80, 136.59;
          800 142.00, 139.60, 137.46, 136.33;
          900 141.45, 139.19, 137.18, 136.11;
          1000  140.99, 138.84, 136.94, 135.92  ];
        
ridx = find(table(:,1)>=N,1);    
cidx = find(table(ridx,2:end)<U,1);

if ~isempty(cidx)
  UC = table(ridx,cidx+1);
  p = alpha(cidx);
else
  UC = table(ridx,end-1);
  p = .5;
end







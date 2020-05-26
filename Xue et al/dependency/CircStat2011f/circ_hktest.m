function [pval table] = circ_hktest(alpha, idp, idq, inter, fn)

%
% [pval, stats] = circ_hktest(alpha, idp, idq, inter, fn)
%   Parametric two-way ANOVA for circular data with interations.
%
%   Input:
%     alpha   angles in radians
%     idp     indicates the level of factor 1 (1:p)
%     idq     indicates the level of factor 2 (1:q)
%     inter   0 or 1 - whether to include effect of interaction or not
%     fn      cell array containing strings with the names of the factors
%               
%
%   Output:
%     pval    vector of pvalues testing column, row and interaction effects
%     table   cell array containg the anova table
%
%   The test assumes underlying von-Mises distributrions.
%   All groups are assumed to have a common concentration parameter k,
%   between 0 and 2.
%
% PHB 7/19/2009 with code by Tal Krasovsky, Mc Gill University
%
% References:
%   Harrison, D. and Kanji, G. K. (1988). The development of analysis of variance for
%   circular data. Journal of applied statistics, 15(2), 197-223.
%
% Circular Statistics Toolbox for Matlab

% process inputs
alpha = alpha(:); idp = idp(:); idq = idq(:);

if nargin < 4
  inter = true;
end

if nargin < 5
  fn = {'A','B'};
end
  

% number of groups for every factor
pu = unique(idp);
p = length(pu);
qu = unique(idq);
q = length(qu);

% number of samples
n = length(alpha);

% compute important sums for the test statistics
cn = zeros(p,q); cr = cn;
pm = zeros(p,1); pr = pm; pn = pm;
qm = zeros(q,1); qr = qm; qn = qm;
for pp = 1:p
    p_id = idp == pu(pp); % indices of factor1 = pp
    for qq = 1:q
        q_id = idq == qu(qq); % indices of factor2 = qq
        idx = p_id & q_id;
        cn(pp,qq) = sum(idx);     % number of items in cell
        cr(pp,qq) = cn(pp,qq) * circ_r(alpha(idx)); % R of cell
    end
    % R and mean angle for factor 1
    pr(pp) = sum(p_id) * circ_r(alpha(p_id));
    pm(pp) = circ_mean(alpha(p_id));
    pn(pp) = sum(p_id);
end

% R and mean angle for factor 2
for qq = 1:q
    q_id = idq == qu(qq);
    qr(qq) = sum(q_id) * circ_r(alpha(q_id));
    qm(qq) = circ_mean(alpha(q_id));
    qn(qq) = sum(q_id);
end

% R and mean angle for whole sample (total)
tr = n * circ_r(alpha);

% estimate kappa
kk = circ_kappa(tr/n);

% different formulas for different width of the distribution
if kk > 2
  % large kappa  
  
  % effect of factor 1
  eff_1 = sum(pr.^2 ./ sum(cn,2)) - tr.^2/n;
  df_1 = p-1;
  ms_1 = eff_1 / df_1;

  % effect of factor 2
  eff_2 = sum(qr.^2 ./ sum(cn,1)') - tr.^2/n;
  df_2 = q-1;
  ms_2 = eff_2 / df_2;

  % total effect
  eff_t = n - tr.^2/n;
  df_t = n-1;

  m = mean(cn(:));
  
  if inter

    % correction factor for improved F statistic
    beta = 1/(1-1/(5*kk)-1/(10*(kk^2)));    
    
    % residual effects
    eff_r = n - sum(sum(cr.^2./cn));
    df_r = p*q*(m-1);
    ms_r = eff_r / df_r;
    
    % interaction effects
    eff_i = sum(sum(cr.^2./cn)) - sum(qr.^2./qn) ...
                  - sum(pr.^2./pn) + tr.^2/n;
    df_i = (p-1)*(q-1);
    ms_i = eff_i/df_i;
    
    % interaction test statistic
    FI = ms_i / ms_r;
    pI = 1-fcdf(FI,df_i,df_r);
    
  else
    
    % residual effect
    eff_r = n - sum(qr.^2./qn)- sum(pr.^2./pn) + tr.^2/n;
    df_r = (p-1)*(q-1);
    ms_r = eff_r / df_r;   
    
    % interaction effects
    eff_i = [];
    df_i = [];
    ms_i =[];
    
    % interaction test statistic
    FI = [];
    pI = NaN;
    beta = 1;
  end
  
  % compute all test statistics as
  %  F = beta * MS(A) / MS(R);

  F1 = beta * ms_1 / ms_r;
  p1 = 1 - fcdf(F1,df_1,df_r);

  F2 = beta * ms_2 / ms_r;
  p2 = 1 - fcdf(F2,df_2,df_r);
  
else
  % small kappa
  
  % correction factor
  rr = besseli(1,kk) / besseli(0,kk);
  f = 2/(1-rr^2);
  
  chi1 = f * (sum(pr.^2./pn)- tr.^2/n);
  df_1 = 2*(p-1);
  p1 = 1 - chi2cdf(chi1, df_1);

  chi2 = f * (sum(qr.^2./qn)- tr.^2/n);
  df_2 = 2*(q-1);
  p2 = 1 - chi2cdf(chi2, df_2);
  
  chiI = f * (sum(sum(cr.^2 ./ cn)) - sum(pr.^2./pn) ...
            - sum(qr.^2./qn)+ tr.^2/n); 
  df_i = (p-1) * (q-1);
  pI = 1 - chi2pdf(chiI, df_i);
  
end

na = nargout;
if na < 2
  printTable;
end

prepareOutput;




  function printTable
    
    if kk>2
    
      fprintf('\nANALYSIS OF VARIANCE TABLE (HIGH KAPPA MODE)\n\n');

      fprintf('%s\t\t\t\t%s\t%s\t\t%s\t\t%s\t\t\t%s\n', ' ' ,'d.f.', 'SS', 'MS', 'F', 'P-Value');
      fprintf('--------------------------------------------------------------------\n');
      fprintf('%s\t\t\t\t%u\t\t%.2f\t%.2f\t%.2f\t\t%.4f\n', fn{1}, df_1 , eff_1, ms_1, F1, p1);
      fprintf('%s\t\t\t\t%u\t\t%.2f\t%.2f\t%.2f\t\t%.4f\n', fn{2}, df_2 , eff_2, ms_2, F2, p2);
      if (inter)
          fprintf('%s\t\t%u\t\t%.2f\t%.2f\t%.2f\t\t%.4f\n', 'Interaction', df_i , eff_i, ms_i, FI, pI);
      end
      fprintf('%s\t\t%u\t\t%.2f\t%.2f\n', 'Residual ', df_r, eff_r, ms_r);
      fprintf('--------------------------------------------------------------------\n');
      fprintf('%s\t\t%u\t\t%.2f', 'Total   ',df_t,eff_t);
      fprintf('\n\n')
    else
      fprintf('\nANALYSIS OF VARIANCE TABLE (LOW KAPPA MODE)\n\n');

      fprintf('%s\t\t\t\t%s\t%s\t\t\t%s\n', ' ' ,'d.f.', 'CHI2', 'P-Value');
      fprintf('--------------------------------------------------------------------\n');
      fprintf('%s\t\t\t\t%u\t\t%.2f\t\t\t%.4f\n', fn{1}, df_1 , chi1, p1);
      fprintf('%s\t\t\t\t%u\t\t%.2f\t\t\t%.4f\n', fn{2}, df_2 , chi2, p2);
      if (inter)
          fprintf('%s\t\t%u\t\t%.2f\t\t\t%.4f\n', 'Interaction', df_i , chiI, pI);
      end
      fprintf('--------------------------------------------------------------------\n');
      fprintf('\n\n')
      
    end
    

  end

  function prepareOutput
    
    pval = [p1 p2 pI];    
    
    if na > 1
      if kk>2
        table = {'Source','d.f.','SS','MS','F','P-Value'; ...
                  fn{1}, df_1 , eff_1, ms_1, F1, p1; ...
                  fn{2}, df_2 , eff_2, ms_2, F2, p2; ...
                  'Interaction', df_i , eff_i, ms_i, FI, pI; ...
                  'Residual', df_r, eff_r, ms_r, [], []; ...
                  'Total',df_t,eff_t,[],[],[]};
      else
        table = {'Source','d.f.','CHI2','P-Value'; ...
          fn{1}, df_1 , chi1, p1;
          fn{2}, df_2 , chi2, p2;
          'Interaction', df_i , chiI, pI};
      end
    end
    
  end


end











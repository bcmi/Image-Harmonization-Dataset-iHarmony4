function dens = productExact(npd_placeholder, npdensities , analyticFns, analyticParams)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% productExact(kde,{kdes} [,{analyticFns},{analyticParams}]);
%          generate the exact density for the product of the input densities
%          this produces an N1xN2xN3x... particle density
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

  for i=1:length(npdensities)
    if (npdensities{i}.type ~= 0) error('Sorry! Product only works for Gaussian densities.'); end;
  end;
  
  Ndens = length(npdensities); Ndim = getDim(npd_placeholder); Nfns = length(analyticFns);
  Np = getNpts(npd_placeholder);    % this is supposed to be how many particles to
                                    % approximate with
  Npts = zeros(Ndens,1); ind = ones(Ndens,1); totalInd = 1;
  for i=1:Ndens, Npts(i) = getNpts(npdensities{i}); end;

  REPEAT = 1;                       % do for exponentially many product particles
  while (REPEAT),                   %  (all combos of input indices)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    ind'  % do what we want with these indices
    for i=1:Ndens,  % Get locations & variance (brute force, lots of repetition)
      particles(:,i) = getPoints(npdensities{i},ind(i));
      variance(:,i)  = getBW(npdensities{i},ind(i)).^2;
    end;

    iC = sum(1./variance,2);                % calculate variance and mean of
    iM = sum(particles./variance,2);        % the product from this index set
    C = 1./iC;
    M = C .* iM;
    m(:,totalInd) = M;                        %  & save them
    c(:,totalInd) = C;

    p(totalInd) = 1;
    for i=1:Ndens,  % Get weight for this combo (again brute force, wasteful)
      p(totalInd) = p(totalInd) * getWeights(npdensities{i},ind(i));
      p(totalInd) = p(totalInd) / (2*pi)^(Ndim/2) / sqrt(prod(variance(:,i)));
      p(totalInd) = p(totalInd) * exp(-.5*sum((particles(:,i)-M).^2 ./ variance(:,i)));
    end;
    p(totalInd) = p(totalInd) * (2*pi)^(Ndim/2) * sqrt(prod(C));
    for k=1:Nfns    % Evaluate analytic functions here too
      pF = feval(analyticFns{k},M,analyticParams{k}{:});
      p(totalInd)  = pF .* p(totalInd);
    end;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if (sum(ind) == sum(Npts)), REPEAT =0; end; % check for end of loop condition

    ind(end) = ind(end)+1;                      % otherwise advance the two counters
    totalInd = totalInd + 1;
    for i=Ndens:-1:2                            % and check for wrapping in the
      if (ind(i)>Npts(i)),                      %   index counters
        ind(i)=1; ind(i-1)=ind(i-1)+1;
      else
        break;
    end; end;
  end;
  p = p ./ sum(p);                              % normalize the weights  
  dens = kde(m,sqrt(c),p);                     % and you've got a KDE
  
  

% Simple Example #3 -- products of gaussian mixtures
%
%
fprintf('KDE Example #3 : Product sampling methods (single, anecdotal run)\n');
rand('state',0);
randn('state',0);

p = kde([.1,.45,.55,.8],.05);  % create a mixture of 4 gaussians for testing
q = kde([.25,.35,.7,.75],.05);  % and another
p = ksize(resample(p,100),'rot');
q = ksize(resample(q,150),'rot'); fprintf('.');
pd = hist(p,100,[1],[0,1]);
qd = hist(q,100,[1],[0,1]);

%pEx = productExact(p,{p,q},{},{}); fprintf('.');
pEx = pd.*qd; pEx = 100*pEx./sum(pEx);
dummy = kde(rand(1,200),1);  % placeholder for productApprox call
pSm = productApprox(dummy,{p,q},{},{},'exact'); fprintf('.');
pEp = productApprox(dummy,{p,q},{},{},'epsilon',1e-3); fprintf('.');
pGi = productApprox(dummy,{p,q},{},{},'gibbs1',100); fprintf('.');
pGM = productApprox(dummy,{p,q},{},{},'gibbsMS1',5); fprintf('.\n');

figure(1); hold off;
plot(linspace(0,1,100),pEx,'r-'); 
hold on;
plot(pSm,'k-'); 
plot(pEp,'g-');
plot(pGi,'c-'); 
plot(pGM,'b-'); 

legend('Discretized','Exact Sampling','Epsilon-Exact','Gibbs1','GibbsMS1');



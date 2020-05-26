% Simple Example #2 -- MI estimates, joinTrees, etc
%
%
fprintf('KDE Example #2 : MI estimates, etc\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Jointly Gaussian with MI = %f (nits)\n',-log(.7));
x = randn(2,1000);
y = [1,.7;.7,1]^.5 * x;
p = kde(y,'rot');
p1 = marginal(p,[1]);
p2 = marginal(p,[2]);
% MI(a,b) = H(a) + H(b) - H(a,b)
MI_est = entropy(p1)+entropy(p2)-entropy(p);
fprintf('   MI_est = %f (nits)\n',MI_est);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Discrete Class Conditionals with MI ~ %f (nits)\n',log(2));
x1 = .1*randn(1,200)+.9;
x2 = .1*randn(1,200)+.1;
p1 = kde(x1,'rot');
p2 = kde(x2,'rot');
p  = joinTrees(p1,p2);
% MI = H(joint) - \sum p(class i) * H(x|class i)
MI_est = entropy(p) - ...
         (getNpts(p1)./getNpts(p))*entropy(p1) -...
         (getNpts(p2)./getNpts(p))*entropy(p2);
fprintf('   MI_est = %f (nits)\n',MI_est);

% Simple Example #1 -- construction, BW choice, plotting
%
%
fprintf('KDE Example #1 : 1D density estimate with various kernels, auto BW choices\n');

p = kde([.1,.45,.55,.8],.08);  % create a mixture of 4 gaussians for testing
x = sample(p,1000);      % and generate samples

figure(1); hold off;
plot(p,'r-'); hold on;
plot(kde(x,'rot'),'b-'); fprintf('.');
plot(kde(x,'lcv'),'b--'); fprintf('.');
plot(kde(x,'hall'),'b:'); fprintf('.');
plot(kde(x,'rot',ones(1,1000),'Epan'),'g-'); fprintf('.'); % Quadratic kernel instead
plot(kde(x,'lcv',ones(1,1000),'Epan'),'g--'); fprintf('.');
plot(kde(x,'hsjm',ones(1,1000),'Epan'),'g:'); fprintf('.\n');

legend('Original','Gauss Kernel, ROT','Gauss Kernel LCV','Gauss Kernel HSJM',...
       'Epan Kernel ROT','Epan Kernel LCV','Epan Kernel HSJM');



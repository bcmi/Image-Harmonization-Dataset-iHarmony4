% Simple Example #3 -- products of gaussian mixtures
%
%
fprintf('Example: Kernel Regression with KDE toolbox\n');
rand('state',0);
randn('state',0);

x = rand(1,200);
y = sin(2*pi*x) + .05*randn(1,200);
bwType = {'rot','lcv','local'}; color = ['g','r','m'];
plot(x,y,'bo');
for j=1:length(bwType)
  px = kde(x,bwType{j}); bwx = getBW(px,1);
  p = kde([x;y],[bwx;0]);
  xx = 0:.01:1; yy = 0*xx;
  for i=1:length(xx)
    yy(i) = mean(condition(p,1,[xx(i);0]));
  end;
  hold on; tmp=plot(xx,yy,[color(j),'-']); set(tmp,'LineWidth',2); hold off;
end;
legend('Samples','ROT kernel size','Likelihd X-Val','Local L. X-val');


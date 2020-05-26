function plotMatch(h,bmap1,bmap2,match1,match2)
% function plotMatch(h,bmap1,bmap2,match1,match2)
% 
% Plot the result of corresondPixels.
%
% David Martin <dmartin@eecs.berkeley.edu>
% January 2003

[y1,x1] = ind2sub(size(match1),find(bmap1));
[y2,x2] = ind2sub(size(match2),find(bmap2));
x2 = x2 + 0.5;
y2 = y2 + 0.5;

edges = [find(match1) match1(find(match1))];
[ym1,xm1] = ind2sub(size(match1),edges(:,1));
[ym2,xm2] = ind2sub(size(match2),edges(:,2));
xm2 = xm2 + 0.5;
ym2 = ym2 + 0.5;

figure(h); clf; hold on;
%set(h,'Color',[1 1 1]);
%plot(x1,y1,'ro','MarkerFaceColor','r');
%plot(x2,y2,'bo','MarkerFaceColor','b');
set(h,'Color',[0 0 0]);
plot(x1,y1,'r.');
plot(x2,y2,'b.');
plot([xm1';xm2'],[ym1';ym2'],'w-');
axis equal; axis ij; axis off;
axis([1 size(match1,2) 1 size(match1,1)]);
%set(gca,'Color',[0 0 0]);


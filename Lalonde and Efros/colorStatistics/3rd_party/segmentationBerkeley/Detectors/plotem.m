
function plotem()

figure(1); clf; hold on;
pr = load('pb/bgtg_0.01_0.02_64/pr.txt');
plot(pr(:,2),pr(:,3),'co-');
pr = load('pb/bgtg/pr.txt');
plot(pr(:,2),pr(:,3),'bx-');
pr = load('pb/cgtg/pr.txt');
plot(pr(:,2),pr(:,3),'rx-');
prplot('');
legend('bgtg zone=2','bgtg zone=10','cgtg');
return

figure(1); clf; hold on;
prplot('all');
pr = load('pb/bgtg_0.01_0.02_64/pr.txt');
plot(pr(:,2),pr(:,3),'c-');
pr = load('pb/bgtg_hys_0.1/pr.txt');
plot(pr(:,2),pr(:,3),'rx-');
pr = load('pb/bgtg_hys_0.3/pr.txt');
plot(pr(:,2),pr(:,3),'ro-');
pr = load('pb/bgtg_hys/pr.txt');
plot(pr(:,2),pr(:,3),'mo-');
pr = load('pb/bgtg_hys_0.5/pr.txt');
plot(pr(:,2),pr(:,3),'rv-');
pr = load('pb/bgtg_hys_0.7/pr.txt');
plot(pr(:,2),pr(:,3),'bx-');
pr = load('pb/bgtg_hys_0.9/pr.txt');
plot(pr(:,2),pr(:,3),'bo-');
legend('base','0.1','0.3','0.4','0.5','0.7','0.9');
return

figure(1); clf; hold on;
pr = load('pb/random/pr.txt');
plot(pr(:,2),pr(:,3),'cx-');
pr = load('pb/gm_2/pr.txt');
plot(pr(:,2),pr(:,3),'mx-');
pr = load('pb/canny_2/pr.txt');
plot(pr(:,2),pr(:,3),'mo-');
pr = load('pb/gm_2_4/pr.txt');
plot(pr(:,2),pr(:,3),'mv-');
pr = load('pb/2mm_2/pr.txt');
plot(pr(:,2),pr(:,3),'gx-');
pr = load('pb/bgtg_0.01_0.02_64/pr.txt');
plot(pr(:,2),pr(:,3),'bx-');
pr = load('pb/bgtg_hys/pr.txt');
plot(pr(:,2),pr(:,3),'bo-');
prplot('all');
legend('random','gm(2)','canny(2)','gm(2,4)','2mm(2)','bgtg','bgtg(hys)');
return

figure(2); clf; hold on;
pr = load('pb/gm_1/pr.txt');
plot(pr(:,2),pr(:,3),'bx-');
pr = load('pb/gm_2/pr.txt');
plot(pr(:,2),pr(:,3),'bv-');
pr = load('pb/gm_4/pr.txt');
plot(pr(:,2),pr(:,3),'b^-');
pr = load('pb/gm_8/pr.txt');
plot(pr(:,2),pr(:,3),'bo-');
pr = load('pb/gm_16/pr.txt');
plot(pr(:,2),pr(:,3),'bs-');
prplot('GM, Single Scale');
legend('gm-1','gm-2','gm-4','gm-8','gm-16');
return

figure(3); clf; hold on;
pr = load('pb/2mm_1/pr.txt');
plot(pr(:,2),pr(:,3),'rx-');
pr = load('pb/2mm_2/pr.txt');
plot(pr(:,2),pr(:,3),'rv-');
pr = load('pb/2mm_4/pr.txt');
plot(pr(:,2),pr(:,3),'r^-');
pr = load('pb/2mm_8/pr.txt');
plot(pr(:,2),pr(:,3),'ro-');
pr = load('pb/2mm_16/pr.txt');
plot(pr(:,2),pr(:,3),'rs-');
prplot('2MM, Single Scale');
legend('2mm-1','2mm-2','2mm-4','2mm-8','2mm-16');

figure(4); clf; hold on;
pr = load('pb/gm_4/pr.txt');
plot(pr(:,2),pr(:,3),'rx-');
pr = load('pb/gm_1_2/pr.txt');
plot(pr(:,2),pr(:,3),'bx-');
pr = load('pb/gm_2_4/pr.txt');
plot(pr(:,2),pr(:,3),'bv-');
pr = load('pb/gm_4_8/pr.txt');
plot(pr(:,2),pr(:,3),'b^-');
prplot('GM, Multi-Scale');
legend('gm-4','gm-1-2','gm-2-4','gm-4-8');

figure(5); clf; hold on;
pr = load('pb/2mm_2/pr.txt');
plot(pr(:,2),pr(:,3),'rx-');
pr = load('pb/2mm_1_2/pr.txt');
plot(pr(:,2),pr(:,3),'bx-');
pr = load('pb/2mm_2_4/pr.txt');
plot(pr(:,2),pr(:,3),'bv-');
prplot('2MM, Multi-Scale');
legend('2mm-2','2mm-1-2','2mm-2-4');

function prplot(ti)
axis([0 1 0 1]); 
axis square;
box on;
xlabel('Recall');
ylabel('Precision');
title(ti);
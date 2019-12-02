% toy test
g1 = [ 1     2     3     1     2     3 ;
       4     5     6     5     6     4 ;
       3     3     3     1     1     5 ];
n = 6;
e1 = csaAssign(n,g1)

% big random test
n = 1000;
dg = (rand(n,n) > 0.5);
m = sum(dg(:));
i = find(dg==1)' - 1;
g2 = [ 1 + floor(i/n) ; 
       1 + mod(i,n) + n ;
       1 + floor(rand(1,m)*1000) ];
tic;
e2 = csaAssign(2*n,g2);
toc;
if sum(e2(1,:)) ~= n*(n+1)/2, error('bug'); end
if sum(e2(2,:)) ~= n*(n+1)/2 + n*n, error('bug'); end
if sum(sum(e2(1:2,:))) ~= 2*n*(2*n+1)/2, error('bug'); end
disp('[n m cost] = ');
[n m sum(e2(3,:))]






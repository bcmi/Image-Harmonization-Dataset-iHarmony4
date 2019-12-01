%
% Internal routines for solving the quadratic minimization problem
% occurring for "reduced set density estimation" (RSDE)
% implemented by the function "@kde/reduce.m"
%
% Code by (a) Chao He and Mark Girolami (SMO, Mult)
%         (b) Yinyu Ye (QP)
%
function alpha = reduceSolve(Q,D,type)
  switch(type)
  case 1,    %Standard Quadratic Optimization
                A = ones(size(Q)); b = ones(size(Q,1),1); c = -D';
                alpha=spsolqp(Q,A,b,c);
  case 2,    %Sequential Minimal Optimisation
                alpha=SMO(Q,D)';
  case 3,    %Multiplicative update optimisation
                alpha=multupd(Q,D);
  end
%  switch(lower(type))
%  case 'qp',    %Standard Quadratic Optimization
%                A = ones(size(Q)); b = ones(size(Q,1),1); c = -D';
%                alpha=spsolqp(Q,A,b,c);
%  case 'smo'    %Sequential Minimal Optimisation
%                alpha=SMO(Q,D)';
%  case 'mult'   %Multiplicative update optimisation
%                alpha=multupd(Q,D);
%  end



function alpha=SMO(Q,D)
%
% Sequential Minimal Optimisation (SMO) algorithm for Reduced Set Density Estimation (RSDE).
%    Minimising 0.5*alpha*Q*alpha'-alpha*D'
%     
%    Use format: alpha=SMO(Q,D)
%
%    Input:  Q [NxN]:        Kernal matrix 
%            D [1xN]:        Parzen density estimate   
%    Return: alpha  [1xN]:   Weight vector obtained by RSDE
%
%    Technical reference: B. Scholkopf, J. Platt and J. Shawe-Taylor et al. "Estimating the support
%            of a high-dimensional distribution", Neural Computation, 13: 1443-1471, 2001.
%
%    Copyright Chao He & Mark Girolami
%    Last revised on January 22th, 2003
%    Acknowledgement: Thanks to Anna Szymkowiak from Technical University of Denmark 
%                     for vectorising certain parts of the code.

%fprintf('Solving method :SMO\n');

%Initialisation
alpha=D./sum(D);
%alpha(1:5),pause;

examineAll=1;
alpha_tolerance=1e-6;  %Tolerance to threshold weight be zero     
error_tolerance=1e-5;  %Iteration error tolerance to terminate the algorithm
E2=[];
stop=0;
loop=0;
loopnum=0;
while (~stop)
    if (examineAll)
        loopnum=loopnum+1;
        fprintf('Loop %d ...\n',loopnum); pause;
        s=find(alpha>alpha_tolerance);
        alpha_tmp=alpha(s);
        [alpha_max,I_max]=max(alpha_tmp);
        I2=s(I_max);
        numChanged=0;
        [alpha,I1,no]=searchPoint(I2,alpha,Q,D);
        numChanged=numChanged+no;
        tt=find(alpha_tmp~=alpha_max&alpha_tmp~=alpha(I1));
        s=s(tt);
        if length(s)==0
            loop=1;
        end
        examineAll=0;
    else
        alpha_tmp=alpha(s);
        [alpha_max,I_max]=max(alpha_tmp);
        I2=s(I_max);
        alpha_bk=alpha;
        [alpha,I1,no]=searchPoint(I2,alpha,Q,D);
        numChanged=numChanged+no;
        ddd=find(alpha_tmp~=alpha_max&alpha_tmp~=alpha(I1));
        s=s(ddd);
        if length(s)==0
            loop=1;
        end
    end
    if loop==1
        E1=0.5*alpha*Q*alpha'-alpha*D';

        E=[E2,E1];
        if E1>E2
            alpha=alpha_bk;
            stop=1;
        else if (abs(E1-E2)<error_tolerance)
                stop=1;
            end
        end
        examineAll=1;
        loop=0;
        E2=E1;
        if numChanged==0
            stop=1;
        else
            examineAll=1;
            loop=0;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [alpha,I1,numChanged]=searchPoint(I2,alpha,Q,D)
% Find the second point to be updated
alpha_tolerance=1e-6;
[N,N]=size(Q);

%%%%%%%%%%%%%%%%%%%
dW=zeros(1,N);
W1=alpha*Q-D;
W2=repmat(alpha*Q(I2,:)'-D(I2),1,N);
ind=find(alpha>alpha_tolerance);
dummy=abs(W1-W2);
dW(1,ind)=dummy(ind);
%%%%%%%%%%%%%%%%%%%%


[dW_max,I1]=max(dW);
dW=W1-W2;
[alpha,numChanged]=updateWeight(I1,I2,alpha,dW(I1),Q);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [alpha,numChanged]=updateWeight(I1,I2,alpha,dW,Q)
%Updating the weights
alpha_tolerance=1e-6;
if I1==I2
    numChanged=0;
    return;
end
if dW==0
    numChanged=0;
    return;
end
if alpha(I1)<alpha_tolerance
    numChanged=0;
    return;
end
alph2=alpha(I2)+dW/(Q(I1,I1)-2*Q(I1,I2)+Q(I2,I2));
if alph2<0
    alph2=0;
end
alph1=alpha(I1)+alpha(I2)-alph2;
if alph1<0
    alph1=0;
    alph2=alpha(I1)+alpha(I2);
end
alpha(I1)=alph1;
alpha(I2)=alph2;
numChanged=1;
%fprintf('I2=%d,  alpha2=%f\n',I2,alpha(I2));
%fprintf('I1=%d,  alpha1=%f\n\n',I1,alpha(I1));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function alpha=multupd(Q,D)
%
% Multiplicative update optimisation algorithm for Reduced Set Density Estimation (RSDE).
%    Minimising 0.5*alpha'*Q*alpha-alpha'*D
%    Updating rule: alpha=(alpha.*D')./(Q*alpha);
%    
%    Technical reference:
%         F. Sha, L. Saul and D. Lee. "Multiplicative updates for non-negative quadratic 
%         programming in support vector machines". Technical report MS-CIS-02-19, University
%         of Pennsylvania, 2002.
%     
%    Use format: alpha=multupd(Q,D)
%
%    Input:  Q [NxN]:        Kernal matrix 
%            D [1xN]:        Parzen density estimate   
%    Return: alpha  [Nx1]:   Weight vector obtained by RSDE
%
%    Copyright Mark Girolami & Chao He
%    Last revised on August 22th, 2002
%

alpha_tolerance=1e-6;  %Tolerance to threshold weight be zero
error_tolerance=1e-9;  %Iteration error tolerance to terminate the algorithm

alpha_tolerance=1e-6;  %Tolerance to threshold weight be zero
error_tolerance=1e-5;  %Iteration error tolerance to terminate the algorithm

%Initialisation 
alpha=D'./sum(D');

alpha(1:5)

err=0.5*alpha'*Q*alpha-alpha'*D';
dE=1;
while abs(dE)>error_tolerance
   a = alpha./(Q*alpha);
   norm_const = (1/sum(a))*(1-sum(a.*D'));
   alpha=a.*(D+norm_const)';

   I=find(alpha<=alpha_tolerance);
   alpha(I)=0.0;
   alpha=alpha./sum(alpha);

   err1=0.5*alpha'*Q*alpha-alpha'*D';
   dE=err1-err;
%   fprintf('Iteration error = %e = %e - %e\n',dE,err1,err); pause;
   fprintf('Iteration error = %f = %f - %f\n',dE,err1,err); pause;
   err=err1;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x,y,obhis]=solqp(Q,A,b,c,toler,beta)
%
% The code is obtained at: http://dollar.biz.uiowa.edu/col/ye/matlab.html
%
%  This program solves quadratic program in standard form:
%
%     minimize    0.5*(x'*Q*x)+c'*x
%     subject to  A*x=b, x>=0.
%
%  Input 
%      Q: Sparse symmetric objective matrix.
%      A: Sparse constraint left-hand matrix
%      b: constraint right-hand column vector
%      c: objective column vector
%      toler: relative stopping tolerance: the objective value close to 
%             the local optimal one in the range of tolerance. 
%             Default value: 1.e-5.
%      beta : step size: 0 < beta < 1. Default value: .95.
%
%  Output
%     x: (local) optimal solution
%     y: optimal dual solution (Lagrangien multiplier)
%     obhis : objective value history vs iterations
%
%  Subroutines called : spphase1 and spphase2
%
%    This program is the implementation of the interior ellipsoidal trust
%    region and barrier function algorithm with dual solution updating
%    technique in the standard QP form. Two phases are used: the first uses 
%    SPPHASE1 to find an interior feasible point and the second uses SPPHASE2
%    to find a local optimal solution.
%
%  Technical Reference
%  
%    Y. Ye, "An extension of Karmarkar's algorithm and the trust region method
%         for convex quadratic programming," in Progress in Mathematical
%         Programming (N. Megiddo ed.), Springer-Verlag, NY (1989) 49-63.
%
%    Y. Ye, "On affine-scaling algorithm for nonconvex quadratic programming,"
%         Math. Programming 56 (1992) 285-300.
%
%  Comment: Each iteration we solve a linear KKT system like
%
%  ( Q+mu X^{-2}   A^T )(dx) = c'
%  (     A          0  )(dy) = 0
%
%  where X = diag(x)  which is a positive diagonal matrix.

%
%  Start Phase 1: try to find an interior feasible point.
%
%
 if exist('toler') ~= 1 
   %toler=1.e-5; 
   toler=1.e-7;
 end
 if exist('beta') ~= 1 
   beta=0.8;    
 end
 if exist('alpha') ~= 1 
   alpha=0.95;    
 end
 [m,n] = size(A);
 %disp('Search for a feasible point:')
 a=b-A*ones(n,1);
 x=ones(n+1,1);
 z=0;
 ob=x(n+1); 
 obhis=[ob];
 gap = ob - z;
 while gap >= toler
   spphase1;
   ob=x(n+1);
   obhis=[obhis ob];
   gap = ob - z;
   if z > 0,
     gap = -1;
     disp('The system has no feasible solution.'),
     return
   end;
 end;
 clear a
% 
% Start Phase 2
%
%
 %disp('Search for an optimal solution:');
 alpha = 0.99;
 x=x(1:n);
 comp=rand(n,1);
 [speye(n) A';A sparse(m,m)]\[comp;sparse(m,1)];
 comp=ans(1:n);
 clear ans;
 nora=min(comp./x);
 if nora < 0
   nora = -.01/nora;
 else
   nora = max(comp./x);
   if nora == 0
     disp('The problem has a unique feasible point');
     return
   end;
   nora = .01/nora;
 end;
 x = x + nora*comp;
 obvalue=x'*(Q*x)/2+c'*x;
 obhis=[obvalue];
 lower =-inf;
 zhis=[lower];
 gap=1;
 lamda=max([1 abs(obvalue)/sqrt(sqrt(n))]);
 iter=0;
 while gap >= toler
   iter=iter+1;
   spphase2;
   if ob == -inf
     gap = 0;
     disp('The problem is unbounded.');
     return
   else 
     obhis=[obhis ob]; 
     comp=Q*x+c-A'*y; 
     if min(comp)>=0 
       zhis(iter+1)=ob-x'*comp;
       lower=zhis(iter+1);
       gap=(ob-lower)/(1+abs(ob));
       obvalue=ob;
     else
       zhis(iter+1)=zhis(iter);     
       lower=zhis(iter+1);
       gap=(obvalue-ob)/(1+abs(ob));
       obvalue=ob;     
     end;
   end;
 end;
 disp('A (local) optimal solution is found.');
 return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% spphase1 
%
% The code is obtained at: http://dollar.biz.uiowa.edu/col/ye/matlab.html
%
% This is the Phase 1 procedure called by SPSOLQP.  
%
%
% Solve the scaled least squares against two vectors
%
 dx = ones(n,1)./x(1:n);
 DD = sparse(1:n,1:n,dx.*dx,n,n);
 [DD A';A sparse(m,m)]\[dx sparse(n,1); sparse(m,1) a];
%
 y1=ans(n+1:n+m,1);
 y2=ans(n+1:n+m,2);
 clear dx ans DD;
 w1=(1/ob - a'*y1)/(1/ob^2 - a'*y2);
 w2=1/(1/ob^2 - a'*y2);
 y1=y1-w1*y2;
 y2=-w2*y2;
%
 w1=b'*y1;
 w2=b'*y2;
 y1=y1/(1+w1);
 y2=y2-w2*y1;
 u=[x(1:n).*(-y2'*A)';x(n+1)*(1-y2'*a);w2/(1+w1)];
 v=[x(1:n).*(y1'*A)' ;x(n+1)*(y1'*a)  ; 1/(1+w1)];
%
%  update the dual and the objective lower bound
%
 if min(u-z*v)>=0,
   y = y2+z*y1;
   z=b'*y;
 end;
 clear y1 y2 w1 w2;
%
%  find the descent direction
%  
 u=u-z*v-((ob-z)/(n+2))*ones(n+2,1);
 nora=max(u);
%
%  update the solution along the descent direction
%
 if nora==u(n+1),
   alpha=1.;
 end;
 v=ones(n+2,1)-(alpha/nora)*u;
 x=(x.*v(1:n+1))/v(n+2);
 clear u v



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  spphase2 
%
% The code is obtained at: http://dollar.biz.uiowa.edu/col/ye/matlab.html
%
%  This is the Phase 2 procedure called by SPSOLQP. 

 lamda=(1.-beta)*lamda;
 go=0;
 dx = ones(n,1)./x;
%
%  Repeatly solve an ellipsoid constrained QP problem by solving a linear
%  system equation until find a positive solution.
%
 while go <= 0,
   DD = sparse(1:n,1:n,(lamda*dx).*dx,n,n);
%
   u=[Q+DD A';A sparse(m,m)]\[-(Q*x+c);sparse(m,1)];
   xx=x+u(1:n);
   go=min(xx);
   if go > 0,
     ob=xx'*Q*xx/2+c'*xx;
     go = min([go obvalue-ob+eps]);
   end;
   lamda=2*lamda;
   if lamda >= (1+abs(obvalue))/toler,
     disp('The problem seems unbounded.');
     return
   end;
 end;
%
 y=-u(n+1:n+m);
 u=u(1:n);
 nora = min(u./x);
 if nora < 0,
   nora=-alpha/nora;
 elseif nora == 0,
   nora=alpha;
 else
   nora=inf;
 end
%
 w1 = u'*Q*u;
 w2 = -u'*(Q*x+c);
 if w1 > 0,
  nora=min([w2/w1,nora]);
 end;
 if nora == inf,
  ob = -inf;
 else
   x =x+nora*u;
   ob=x'*Q*x/2+c'*x;
 end;
 clear u dx xx DD w1 w2



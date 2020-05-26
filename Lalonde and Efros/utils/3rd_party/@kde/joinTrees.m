function t1 = joinTrees(t1, t2, alpha)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% t12 = joinTrees(t1, t2, alpha)
%   create a new KD-tree with t1 and t2 as the children of the root
%   The t1 subtree recieves weight alpha; the t2 subtree has wt. 1-alpha
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

if(t1.D ~= t2.D)
  error('Input trees have different dimensionality!');
end

if(isfield(t1, 'type') ~= isfield(t2, 'type'))
  error('Cant merge BallTree with BallTreeDensity!');
end

if(t1.type ~= t2.type)
  error('Trees must have the same type of kernel!');
end

if(nargin < 2 || nargin > 3)
  error('wrong number of arguments');
end
if(nargin == 2)
  alpha = 0.5;
end

% leave off one of the zeros between leaves and nodes
if(t1.N==1) t1nodes = []; t1leaves=[1]; 
  else t1nodes = [1:t1.N-1]; t1leaves = [t1.N+1:2*t1.N]; end;
if(t2.N==1) t2nodes = []; t2leaves = [1];
  else t2nodes = [1:t2.N-1]; t2leaves = [t2.N+1:2*t2.N]; end;

if(t1.N~=1) t1root=2;
else t1root=3+length(t2nodes);
end
if(t2.N~=1) t2root=2+length(t1nodes);
else t2root=3+length(t1nodes)+length(t1leaves);
end
t1N = t1.N;
t1.N = t1.N + t2.N;

Os = zeros(t1.D, 1);

t1.centers = [Os t1.centers(:,t1nodes) t2.centers(:,t2nodes) Os ...
              t1.centers(:,t1leaves) t2.centers(:,t2leaves)];
t1.ranges = [Os t1.ranges(:,t1nodes) t2.ranges(:,t2nodes) Os t1.ranges(:,t1leaves) ...
             t2.ranges(:,t2leaves)];
t1.weights = [0 alpha*t1.weights(t1nodes) (1-alpha)*t2.weights(t2nodes) 0 ...
              alpha*t1.weights(t1leaves) (1-alpha)*t2.weights(t2leaves)];

t1.means = [Os t1.means(:,t1nodes) t2.means(:,t2nodes) Os ...
            t1.means(:,t1leaves) t2.means(:,t2leaves)];

% take care of variable BWs
t1varBWs = size(t1.bandwidth, 2) > 2*t1N;
t2varBWs = size(t2.bandwidth, 2) > 2*t2.N;
varBWs = t1varBWs || t2varBWs || ...
         sum(t1.bandwidth(:,1) ~= t2.bandwidth(:,1)) > 0;
if(varBWs)
  t1.bandwidth = [Os t1.bandwidth(:,t1nodes) t2.bandwidth(:,t2nodes) ...
                  Os t1.bandwidth(:,t1leaves) t2.bandwidth(:,t2leaves) ...
                  Os t1.bandwidth(:,t1nodes+2*t1N*t1varBWs) ...
                  t2.bandwidth(:,t2nodes+2*t2.N*t2varBWs) Os ...
                  t1.bandwidth(:,t1leaves+2*t1N*t1varBWs) ...
                  t2.bandwidth(:,t2leaves+2*t2.N*t2varBWs) Os ...
                  t1.bandwidth(:,t1nodes+4*t1N*t1varBWs) ...
                  t2.bandwidth(:,t2nodes+4*t2.N*t2varBWs) Os ...
                  t1.bandwidth(:,t1leaves+4*t1N*t1varBWs) ...
                  t2.bandwidth(:,t2leaves+4*t2.N*t2varBWs) ];
else
  t1.bandwidth = [Os t1.bandwidth(:,t1nodes) t2.bandwidth(:,t2nodes) ...
                  Os t1.bandwidth(:,t1leaves) t2.bandwidth(:,t2leaves)];
end

%%%% Do stuff from calcStats because calcStats is protected.  Don't
% change calc stats or this won't work.

ax = max(t1.centers(:,t1root)+t1.ranges(:,t1root), ...
         t1.centers(:,t2root)+t1.ranges(:,t2root));
in = min(t1.centers(:,t1root)-t1.ranges(:,t1root), ...
         t1.centers(:,t2root)-t1.ranges(:,t2root));
t1.centers(:,1) = (ax+in)/2;
t1.ranges(:,1) = (ax-in)/2;


%calcuate weight
t1.weights(1) = t1.weights(t1root) + t1.weights(t2root);
W = sum(t1.weights(t1.N+1:2*t1.N));
t1.weights = t1.weights / W;  % normalize
t1w = t1.weights(t1root) / t1.weights(1);
t2w = t1.weights(t2root) / t1.weights(1);

%calculate mean
t1.means(:,1) = t1w*t1.means(:,t1root) + t2w*t1.means(:,t2root);

%calculate bandwidth
type = getType(t1);
if(strcmp(type, 'Gaussian'))
  t1.bandwidth(:,1) = t1w * (t1.bandwidth(:,t1root) + t1.means(:,t1root).^2) ...
      + t2w * (t1.bandwidth(:,t2root) + t1.means(:,t2root).^2) - ...
      t1.means(:,1).^2;
elseif(strcmp(type, 'Epanetchnikov'))
  t1.bandwidth(:,1) = sqrt(.5 * (t1w * (2*t1.bandwidth(:,t1root).^2 ...
                                                 + t1.means(:,t1root).^2) ...
                                + t2w * (2*t1.bandwidth(:,t2root).^2 ...
                                                   + t1.means(:,t2root).^2) ...
                                - t1.means(:,1).^2));
elseif(strcmp(type, 'Laplacian'))
  t1.bandwidth(:,1) = sqrt(5 * (t1w * (.2*t1.bandwidth(:,t1root).^2 ...
                                                + t1.means(:,t1root).^2) ...
                               + t2w * (.2*t1.bandwidth(:,t2root).^2 ...
                                                  + t1.means(:,t2root).^2) ...
                               - t1.means(:,1).^2));    
else
  error(['unknown kernel type: ' type])
end

% take care of max and min BWs for variable bandwidths
if(varBWs)
  t1.bandwidth(:,1+2*t1.N) = max(t1.bandwidth(:,t1root+2*t1.N), t1.bandwidth(:,t2root+2*t1.N));
  t1.bandwidth(:,1+4*t1.N) = min(t1.bandwidth(:,t1root+4*t1.N), t1.bandwidth(:,t2root+4*t1.N));
end


t1n = 1;
t2n = 1 + length(t1nodes);
t1l = 1 + length(t2nodes);
t2l = 1 + length(t1nodes) + length(t1leaves);

% arrays are zero indexed
t1.lower = [t1.N addUints(t1.lower(t1nodes),t1l) ...
           addUints(t2.lower(t2nodes),t2l) 0 ...
           addUints(t1.lower(t1leaves),t1l) ...
           addUints(t2.lower(t2leaves),t2l)];
t1.upper = [2*t1.N-1 addUints(t1.upper(t1nodes),t1l) ...
           addUints(t2.upper(t2nodes),t2l) 0 ...
           addUints(t1.upper(t1leaves),t1l) ...
           addUints(t2.upper(t2leaves),t2l)];

t1leftch = addUints(t1.leftch, (t1.leftch < t1N) * t1n + ...
                     (t1.leftch >= t1N) * t1l);
t2leftch = addUints(t2.leftch, (t2.leftch < t2.N) * t2n + ...
                     (t2.leftch >= t2.N) * t2l);
t1rightch = addUints(t1.rightch, (t1.rightch < t1N) * t1n + ...
                     (t1.rightch >= t1N) .* (t1.rightch < 4e9) * t1l);
t2rightch = addUints(t2.rightch, (t2.rightch < t2.N) * t2n + ...
                     (t2.rightch >= t2.N) .* (t2.rightch < 4e9) * t2l);

t1.leftch = [d2uint(t1root) t1leftch(t1nodes) t2leftch(t2nodes) ...
             0 t1leftch(t1leaves) t2leftch(t2leaves)];
t1.rightch = [d2uint(t2root) t1rightch(t1nodes), t2rightch(t2nodes) ...
              0 t1rightch(t1leaves) t2rightch(t2leaves)];
t1.perm = [0 t1.perm(t1nodes) t2.perm(t2nodes) 0 t1.perm(t1leaves) ...
          addUints(t2.perm(t2leaves),length(t1leaves))];

function c = addUints(a, b)
c = uint32(double(a) + double(b));

function u = d2uint(d)
u = uint32(d - 1);

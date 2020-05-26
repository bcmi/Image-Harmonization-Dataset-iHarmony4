function progbar(i,n,w)
% function progbar(i,n,w)
%
% Display a textual progress bar.
%
% INPUTS
%	i	Iteration number.
%	n	Number of iterations.
%	[w=50]	Width of bar.
%
% EXAMPLE
%
% 	progbar(0,n);
% 	for i = 1:n,
% 	  compute();
% 	  progbar(i,n);
% 	end
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% April 2002

if nargin<3, w=50; end
w = min(w,n);

if i==0,
  fwrite(2,'[');
  for c = 1:w, fwrite(2,'.'); end
  fwrite(2,']');
  for c = 1:w+1, fwrite(2,sprintf('\b')); end
  return
end

if mod(i,n/w) <= mod(i-1,n/w),
  fwrite(2,'=');
end

if i==n,
  fprintf(2,'\n');
end

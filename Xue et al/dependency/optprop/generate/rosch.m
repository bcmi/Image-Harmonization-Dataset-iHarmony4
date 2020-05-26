function r=rosch(varargin)
%ROSCH Create the Rosch color solid.
%   ROSCH creates the ROSCH color solid as spectra or XYZ
%   Z=ROSCH(N) with scalar N, returns an matrix with size(Z)=[N+1 2N+1 N]
%   where the last dimension is the spectral dimension.
%   Z=ROSCH(LAM) with vector LAM, returns matrix with size(Z)=[N+1 2N+1 3]
%   where Z is the XYZ values for the corresponding spectrum and N=length(LAM).
%   The XYZ-version takes longer time but can be motivated when N is large, since
%   the returned value can be huge.
%   ROSCH(N,ALIGN), where ALIGN is logical true, returns an aligned version
%   that has size(Z)=[N+1 N+1 N] and does not contain any NaNs. This layout
%   is not suitable for volume plots though. If omitted, ALIGN is false.
%
%   Example:
%      r=rosch;
%      viewlab(roo2lab(r));
%
%   See also VIEWLAB

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: rosch.m 23 2007-01-28 22:55:34Z jerkerw $


	lam=[];
	IllObs=[];
	pvix=1;
	if nargin==0
		n=length(dwl);
	else
		if isscalar(varargin{1})
			n=varargin{1};
			pvix=2;
		elseif iscwf(varargin{1})
			IllObs=varargin{1};
			if nargin>=2 && iswlrange(varargin{2})
				lam=optgetpref('WLRange',varargin{2});
				n=length(lam);
				pvix=3;
			else
				lam=dwl;
				n=length(lam);
				pvix=2;
				end
		elseif iswlrange(varargin{1})
			lam=varargin{1};
			n=length(lam);
			pvix=2;
		else
			n=length(dwl);
			end
		end
	if pvix<=nargin && ~ischar(varargin{pvix})
		error(illpar('Call as (), (n) or (IllObs<,WLRange>)'));
		end
	Default=struct('Align',true);
	par=args2struct(Default,varargin(pvix:end));
	align=par.Align;
	m=iif(isempty(lam),n,3);

	% Preallocate result
	r=zeros(iif(align,2,1)*n+1,m,n+1);
	for p = 0:n
		r1=flipdim(100*[nan*zeros(iif(align,p,0),n)
			ones(n-p,p) triu(ones(n-p))
			triu(ones(p)) zeros(p,n-p)
			zeros(1,n)
			nan*zeros(iif(align,n-p,0),n)
			], 1);

		% The flipdim further below is for getting the L values to increase
		% with increasing indices in both rows and columns. It will make
		% interpolation easier. It is most certainly possible to rearrange
		% the r matrix above to eliminate this flipud, but that is left as
		% an excercise for the reader ...

		if isempty(lam)
			r(:,:,p+1) = r1;
		else
			r(:,:,p+1) = roo2xyz(r1,IllObs,lam);
			end
		end
	r=flipdim(shiftdim(r,2),1);

function z=iif(b,t,f)
	if b
		z=t;
	else
		z=f;
		end

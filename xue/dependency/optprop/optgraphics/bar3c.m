function h=bar3c(varargin)
%BAR3C Plot 3-D bar chart in true color
%   BAR3(Y,Z,RGB) draws the columns of the M-by-N matrix Z as vertical 3-D
%   bars.  The vector Y must be monotonically increasing or decreasing. RGB
%   holds the color for each bar and must be an M-by-N-by-3 matrix
%
%   BAR3(Z,RGB) uses the default value of Y=1:M.  For vector inputs,
%   BAR3(Y,Z,RGB) or BAR3(Z,RGB) draws LENGTH(Z) bars.
%
%   BAR3(Y,Z,RGB,WIDTH) or BAR3(Z,RGB,WIDTH) specifies the width of the
%   bars. Values of WIDTH > 1, produce overlapped bars.  The default
%   value is WIDTH=0.8
%
%   BAR3(...,'detached') produces the default detached bar chart.
%   BAR3(...,'grouped') produces a grouped bar chart.
%   BAR3(...,'stacked') produces a stacked bar chart.
%   BAR3(...,LINESPEC) uses the line color specified (one of 'rgbymckw').
%
%   BAR3(AX,...) plots into AX instead of GCA.
%
%   H = BAR(...) returns a vector of surface handles in H.
%
%   Remark:
%      This is just a simple wrapper around Matlab's standard BAR3 and the
%      help text above is taken almost directly from BAR3.
%
%   Example:
%       subplot(1,2,1), bar3c(peaks(5),rand(5,5,3))
%       subplot(1,2,2), bar3c(rand(5),rand(5,5,3),'stacked')
%
%   See also BAR, BARH, and BAR3H.

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: bar3c.m 23 2007-01-28 22:55:34Z jerkerw $

	error(nargchk(1,inf,nargin,'struct'));
	[cax,args] = axescheck(varargin{:});
	if isempty(cax)
		cax={};
	else
		cax={cax};
		end
	ix=0;
	for i=1:length(args)
		if isdatapair(args,i)
			ix=i;
			break;
			end
		end
	if ix
		rgb=args{ix+1};
		args(ix+1)=[];
	else
		error(illpar('Color spec missing or badly formed'));
		end
	hb=bar3(cax{:},args{:});
	[rows,cols,dummy]=size(rgb); %#ok<NASGU>
	rgb=reshape(rgb,[rows,1,1,cols,3]);
	rgb=repmat(rgb,[1 6 4 1 1]);
	rgb=permute(rgb,[2 1 3 4 5]);
	rgb=reshape(rgb,[6*rows 4 cols 3]);
	rgb=permute(rgb,[1 2 4 3]);
	CData=squeeze(mat2cell(rgb,6*rows,4,3,ones(cols,1)));
	set(hb,{'CData'},CData);
	if nargout
		h=hb;
		end

function z=isdatapair(args,ix)
	if length(args)>ix
		szc=size(args{ix+1});
		z=isnumeric(args{ix}) ...
			&& length(szc) == 3 ...
			&& szc(3)==3 ...
			&& isequal(size(args{ix}),szc(1:2));
	else
		z=false;
		end

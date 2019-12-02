function xyz=i_xyz2xyz(xyz,cwfs,cwfd,varargin)
%I_XYZ2XYZ Adapt XYZ to another illuminant/observer.
%   AXYZ=I_XYZ2XYZ(XYZ,CWFSRC,CWFDST) with size(XYZ)=[M N ... P 3] returns
%   matrix AXYZ with same size.
%
%   CWFSRC and CWFDST are color weighting function specifications. They can
%   be strings, e.g. 'D50/2', or structs, see MAKECWF. If omitted or empty,
%   the default cwf, DCWF is used.
%
%   ...=XYZ2XYZ(...,'CAT',C) with string C, defines which
%   chromatic adaptation transform to use. C can be one of 'none' 'xyz',
%   'bradford' or 'vonkries'. Default = 'bradford'.
%
%   Example:
%      axyz=i_xyz2xyz([30 30 30],'D65/10','D50/2', 'CAT', 'bradford');
%

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_xyz2xyz.m 24 2007-01-28 23:20:35Z jerkerw $

	Default=struct('cat', 'bradford');
	par=args2struct(Default, varargin);
	par.cat=partialmatch(par.cat, {'none', 'xyz', 'bradford', 'vonkries'});
	if ~strcmp(par.cat, 'none')
		wpd=wpt(cwfd);
		wps=wpt(cwfs);
		if ~all(isnear(wpd,wps))
			C=M(par.cat);
			T=C*diag((wpd*C)./(wps*C))*inv(C);
			xyz=xyz*T;
			end
		end
	end

function z=M(Transform)
	persistent ca
	
	if isempty(ca)
		ca=[ 1.0       0.0       0.0      0.0       1.0       0.0      0.0       0.0       1.0    
			 0.8951   -0.7502    0.0389   0.2664    1.7135   -0.0685  -0.1614    0.0367    1.0296
			 0.40024  -0.22630   0.00000  0.70760   1.16532   0.00000 -0.08081   0.04570   0.91822];
		end
	z=reshape(ca(strmatch(Transform,{'xyz', 'bradford', 'vonkries'}, 'exact'),:),3,3)';
	end

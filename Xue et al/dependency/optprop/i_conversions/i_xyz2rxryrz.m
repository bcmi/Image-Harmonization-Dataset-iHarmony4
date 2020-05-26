function RxRyRz=i_xyz2rxryrz(XYZ,IllObs)
%I_XYZ2RXRYRZ Convert from XYZ to RxRyRz.
%   RXRYRZ=I_XYZ2RXRYRZ(XYZ,CWF) with size(XYZ)=[M 3] returns matrix RXRYRZ
%   with same size.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, OPTGETPREF('cwf') is used.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use XYZ2RXRYRZ instead.
%
%   Example:
%      i_xyz2rxryrz([20 30 40],'D65/10')
%
%   See also: XYZ2RXRYRZ, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_xyz2rxryrz.m 24 2007-01-28 23:20:35Z jerkerw $

	IllObs=[cwf2ill(IllObs) '/' cwf2obs(IllObs)];
	switch upper(IllObs)
		case 'C/2'
			abc=1./[0.783185 0.19752 1.182264];
		case 'D65/10'
			abc=1./[0.768417 0.179707 1.073241];
		otherwise
			error(illpar('Can only handle C/2 and D65/10'));
		end
	RxRyRz=XYZ * [ ...
				abc(1)				0	0
				0					1	0
		-prod(abc([1 3]))/abc(2)	0	abc(3)];

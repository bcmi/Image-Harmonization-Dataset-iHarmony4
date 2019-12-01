function wtj=i_xyz2wtj(XYZ,IllObs)
%I_XYZ2WTJ Convert from XYZ to CIE Whiteness, T(Red Tint) and J (Yellowness).
%   WTJ=I_XYZ2WTJ(XYZ,CWF) with size(XYZ)=[M 3] returns matrix WTJ with
%   same size.
%
%   CWF is a color weighting function specification. It can be a
%   string, e.g. 'D50/2', or a struct, see MAKECWF. If empty, the
%   the default cwf, OPTGETPREF('cwf') is used.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use XYZ2WTJ instead.
%
%   See also: XYZ2WTJ, I_WTJ2XYZ, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_xyz2wtj.m 24 2007-01-28 23:20:35Z jerkerw $

	obs=cwf2obs(IllObs);
	if ~isequal(obs,'2') && ~isequal(obs,'10')
		error(illpar('Observer must be ''2'' or ''10'''));
		end
	xy=xyz2xy(XYZ);
	xyn=i_xyz2xy(wpt(IllObs));
	wtj = XYZ(:,2) + 800 * (xyn(1) - xy(:,1)) + 1700 * (xyn(2) - xy(:,2));
	if strcmp(obs,'10')
		xFactor = 900;
	else
		xFactor = 1000;
		end
	wtj(:,2) = xFactor * (xyn(1) - xy(:,1)) - 650 * (xyn(2) - xy(:,2));
	try
		r = i_xyz2rxryrz(XYZ, IllObs);
		ws=warning('off', 'MATLAB:divideByZero');
		wtj(:,3) = 100 * (r(:,1) - r(:,3)) ./ r(:,2);
		warning(ws);
	catch
		wtj(:,3)=nan;
		end

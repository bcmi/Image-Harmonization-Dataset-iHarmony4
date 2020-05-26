function z=wpt(cwf)
%WPT Returns the whitepoint of a color weighting functions specification
%   Z=WPT(CWF), where CWF is a color weighting function specification,
%   returns the whitepoint associated with the CWF as tristimulus XYZ.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   Remark:
%      A much better name for this routine would have been simply
%      'whitepoint', but that name was unfortunately for OptProp already
%      'taken' by Mathworks' image processing toolbox.
%
%   Example:
%      Display the whitepoint for illuminant D50 and the 1964 10 degree
%      observer:
%         wpt('D65/10');


% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: wpt.m 36 2007-02-05 13:15:34Z jerkerw $

	error(nargchk(0,1,nargin,'struct'));
	if nargin<1 || isempty(cwf);cwf=dcwf;end
	if ~iscwf(cwf)
		error(illpar('Not a valid color weighting function specification'));
		end
	if ischar(cwf)
		cwf=makecwf(cwf);
		end
	z=cwf.whitepoint;

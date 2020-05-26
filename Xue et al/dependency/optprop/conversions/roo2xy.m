function varargout=roo2xy(varargin)
%ROO2XY Convert from spectra to chromaticity x and y.
%   XY=ROO2XY(ROO,CWF,WL) with size(ROO)=[M N ... P W] returns
%   matrix XY with size [M N ... P 2].
%
%   [X,Y]=ROO2XY(ROO,CWF,WL) with size(ROO)=[M N ... P W] returns
%   matrices X and Y, each with size [M N ... P].
%
%   ROO holds M*N*...*P spectral readings with W spectral bands and WL,
%   size [1 W], holds the wavelengths. If WL is omitted or empty, the
%   default wave- length range, DWL, is used for WL.
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If omitted or empty, the
%   default cwf, DCWF is used.
%
%   Example:
%      Show a Macbeth ColorChecker in xy-space
%
%         [x,y]=roo2xy(colorchecker);
%         rgb=roo2rgb(colorchecker, 'srgb');
%         helmholtz;
%         hold on
%         scatter(x(:),y(:),200,reshape(rgb,[],3),'filled');
%         hold off
%         axis equal
%
%   See also: MAKECWF, OPTGETPREF, I_ROO2XY

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: roo2xy.m 24 2007-01-28 23:20:35Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([1 0 2 0],[1 5],@i_roo2xy,varargin{:});
	error(err);


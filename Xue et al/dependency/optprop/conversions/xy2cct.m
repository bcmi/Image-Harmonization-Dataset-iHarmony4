function varargout=xy2cct(varargin)
%XYZ2CCT Calculate correlated color temperature.
%   CCT=XY2CCT(XY) with size(xyz)=[M N ... P 2] returns
%   matrix CCT with size [M N ... P].
%
%   CCT=XY2CCT(X,Y) with size(X,Y)=[M N ... P] returns
%   matrix CCT with size [M N ... P].
%
%	Example:
%      Find the correlated color temperatur for D65 with 2 degrees observer:
%
%         xy2cct(xyz2xy(wpt('D65/2'))) % returns CCT for D65
%
%   See: ROO2CCT, BLACKBODY, DILL

%   Wrapper and transcriber: Jerker Wågberg, 2005-03-30
%   Author: Neil Okamoto
%   Original at http://www.efg2.com/Lab/Library/UseNet/2001/0714.txt

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: xy2cct.m 31 2007-01-29 22:24:02Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([2 0 0 0],[],@i_xy2cct,varargin{:});
	error(err);

function varargout=srgbgamma(varargin)
%SRGBGAMMA Apply the special SRGB gamma function to RGB data.
%   ARGB=SRGBGAMMA(RGB,DIR) with size(RGB)=[M N ... P 3]
%   returns matrix ARGB with same size.
%
%   ARGB=SRGBGAMMA(R,G,B,DIR) with size of R,G,B = [M N ... P]
%   returns matrix ARGB with size [M N ... P 3].
%
%   [AR,AG,AB]=SRGBGAMMA(RGB,DIR) size(RGB)=[M N ... P 3] returns
%   matrices AR, AG and AB, each with size [M N ... P].
%
%   [AR,AG,AB]=SRGBGAMMA(R,G,B,DIR) size(R,G,B)=[M N ... P] returns
%   returns equally sized matrices AR, AG and AB.
%
%   DIR is the direction of gamma conversion. Linear RGB values are converted
%   to nonlinear by DIR='inverse' and nonlinear sRGB values to linear RGB
%   by DIR='forward'.
%
%   [...]=SRGBGAMMA(..., 'CLIP', C) with C={'on'|'off'} enables or disables
%   input limiting between [0,1]. Default 'on'.
%
%   Example:
%      To convert linear rgb values to nonlinear rgb, use:
%
%	      srgbgamma([.1 .1 .1], 'inverse')
%
%   See also LAB2RGB, XYZ2RGB, RGB2LAB, RGB2XYZ, I_SRGBGAMMA

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: srgbgamma.m 24 2007-01-28 23:20:35Z jerkerw $


	[err,varargout{1:max(1,nargout)}]=optproc([3 1 0 1], 0,@i_srgbgamma,varargin{:});
	error(err);


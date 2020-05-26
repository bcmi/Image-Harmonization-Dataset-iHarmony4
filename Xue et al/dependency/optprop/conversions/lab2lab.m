function varargout=lab2lab(varargin)
%LAB2LAB Adapt LAB to another illuminant/observer.
%   ALAB=LAB2LAB(LAB,CWFS,CWSD) with size(LAB)=[M N ... P 3] returns
%   matrix ALAB with same size. The Lab values are converted from being
%   relative the illuminant/observer implied by CWFS into being relative to
%   the ones in CWFD.
%
%   ALAB=LAB2LAB(L,A,B,CWFS,CWSD) with size(L,A,B)=[M N ... P] returns
%   matrix ALAB with size [M N ... P 3].
%
%   [AL,AA,AB]=LAB2LAB(LAB,CWFS,CWSD) with size(LAB)=[M N ... P 3] returns
%   matrices AL, AA and AB, each with size [M N ... P].
%
%   [AL,AA,AB]=LAB2LAB(L,A,B,CWFS,CWSD) with size(L,A,B)=[M N ... P]
%   returns equally sized matrices AL, AA and AB.
%
%   CWFS and CWSD are a color weighting function specifications. They can
%   be a strings, e.g. 'D50/2', or structs, see MAKECWF. If omitted or
%   empty, the default cwf, DCWF is used.
%
%   ...=LAB2LAB(...,'cat',C) with string C, defines which chromatic
%   adaptation transform to use. C can be any one of 'none' 'xyz', 'bradford'
%   or 'vonkries'. Default is 'bradford'.
%
%   Example:
%      Convert Lab value from the illuminant/observer (D65/10) to
%      D50/2 and visualize the difference in Lab values.
%
%         lab=roo2lab(colorchecker,'D65/10');
%         alab=lab2lab(lab,'D65/10','D50/2','cat','bradford');
%         rgb=lab2disp(lab,'D65/10'); % Use D65/10 colors
%         d=de(lab,alab);
%         ballplot(lab(:,:,[2 3 1]),rgb,d+1);
%         camlight;
%		  lighting phong
%
%   See also XYZ2XYZ, RGB2RGB, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: lab2lab.m 23 2007-01-28 22:55:34Z jerkerw $


	[err,varargout{1:max(1,nargout)}]=optproc([3 2 0 1],[1 1],@i_lab2lab,varargin{:});
	error(err);


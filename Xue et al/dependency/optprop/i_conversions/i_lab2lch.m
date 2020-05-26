function Lch=i_lab2lch(Lab)
%I_LAB2LCH Convert from Lab to LCH.
%   LCH=LAB2LCH(LAB) with size(LAB)=[M N ... P 3] returns matrix LCH with
%   same size.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use LAB2LCH instead.
%
%   Example:
%      i_lab2lch([45 30 40])
%
%   See also: LAB2LCH, I_LCH2LAB, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_lab2lch.m 24 2007-01-28 23:20:35Z jerkerw $

	Lch=zeros(size(Lab));
	Lch(:,1)=Lab(:,1);
	Lch(:,2)=hypot(Lab(:,2),Lab(:,3));
	Lch(:,3)=180/pi*atan2(Lab(:,3),Lab(:,2));
	ix=Lch(:,3)<0;
	Lch(ix,3)=Lch(ix,3)+360;

function Lab=i_lch2lab(LCh)
%I_LAB2LCH Convert from LCh to Lab.
%   LAB=I_LCH2LAB(LCH) with size(LCH)=[M 3] returns matrix LAB with
%   same size.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use LCH2LAB instead.
%
%   See also: LCH2LAB, I_LAB2LCH, MAKECWF, OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_lch2lab.m 24 2007-01-28 23:20:35Z jerkerw $

	Lab=[LCh(:,1) LCh(:,2).*[cosd(LCh(:,3)) sind(LCh(:,3))]];

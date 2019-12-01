function z=i_xy2cct(xy)
%I_XYZ2CCT Calculate correlated color temperature.
%   CCT=I_XY2CCT(XYZ) with size(XYZ)=[M N ... P 2] returns
%   matrix CCT with size [M N ... P].
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use XY2CCT instead.
%
%	Example:
%      Find the correlated color temperatur for D65 with 2 degrees observer:
%
%         i_xy2cct(i_xyz2xy(wpt('D65/2'))) % returns CCT for D65
%
%   See: ROO2CCT, BLACKBODY, DILL

%   Wrapper and transcriber: Jerker Wågberg, 2005-03-30
%   Author: Neil Okamoto
%   Original at http://www.efg2.com/Lab/Library/UseNet/2001/0714.txt
%

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_xy2cct.m 23 2007-01-28 22:55:34Z jerkerw $

	% convert (x,y) to CIE 1960 (u,v)
	denom=-xy(:,1) + 6*xy(:,2) + 1.5;
	us = (2*xy(:,1)) ./ denom;
	vs = (3*xy(:,2)) ./ denom;

	z=cct(us,vs);

function t=cct(us,vs)
	% Computes correlated color temperature based on Robertson's method.
	% (cf. Wyszecki & Stiles, p.224-9)
	%
	persistent mirek ut vt tt
	if isempty(mirek)
		% ut(20) changed from W&S 0.24702 to 0.24792
		isodata=[ ...
			0,    0.18006,  0.26352,   -0.24341
		   10,    0.18066,  0.26589,   -0.25479
		   20,    0.18133,  0.26846,   -0.26876
		   30,    0.18208,  0.27119,   -0.28539
		   40,    0.18293,  0.27407,   -0.30470
		   50,    0.18388,  0.27709,   -0.32675
		   60,    0.18494,  0.28021,   -0.35156
		   70,    0.18611,  0.28342,   -0.37915
		   80,    0.18740,  0.28668,   -0.40955
		   90,    0.18880,  0.28997,   -0.44278
		   100,   0.19032,  0.29326,   -0.47888
		   125,   0.19462,  0.30141,   -0.58204
		   150,   0.19962,  0.30921,   -0.70471
		   175,   0.20525,  0.31647,   -0.84901
		   200,   0.21142,  0.32312,   -1.0182 
		   225,   0.21807,  0.32909,   -1.2168 
		   250,   0.22511,  0.33439,   -1.4512 
		   275,   0.23247,  0.33904,   -1.7298 
		   300,   0.24010,  0.34308,   -2.0637 
		   325,   0.24792,  0.34655,   -2.4681 
		   350,   0.25591,  0.34951,   -2.9641 
		   375,   0.26400,  0.35200,   -3.5814 
		   400,   0.27218,  0.35407,   -4.3633 
		   425,   0.28039,  0.35577,   -5.3762 
		   450,   0.28863,  0.35714,   -6.7262 
		   475,   0.29685,  0.35823,   -8.5955 
		   500,   0.30505,  0.35907,  -11.324 
		   525,   0.31320,  0.35968,  -15.628 
		   550,   0.32129,  0.36011,  -23.325 
		   575,   0.32931,  0.36038,  -40.770 
		   600,   0.33724,  0.36051, -116.45
		   ];
		mirek=isodata(:,1);	% temp (in microreciprocal kelvin)
		ut=isodata(:,2);	% u coord of intersection w/ blackbody locus
		vt=isodata(:,3);	% v coord of intersection w/ blackbody locus
		tt=isodata(:,4);	% slope of isotemp. line
		end

	% search for closest isotemp lines
	t=nan*zeros(size(us));
	ix=true(size(us));
	j=1;
	while any(ix) && j<=length(mirek)
		% dj = distance from (us,vs) to this isotemp line */
		dj(ix) = ((vs(ix) - vt(j)) - tt(j) * (us(ix) - ut(j))); %#ok<AGROW>

		ixe=false(size(ix));
		if j>1
			% we stop when di and dj changes sign, because this means we have
			% found isotemp lines that "straddle" our point.
			ixe(ix)=j>1 & (di(ix)<0 & dj(ix)>0 | di(ix)>0 & dj(ix)<0);
			dit=di(ixe)/sqrt(1+tt(j-1).^2);
			djt=dj(ixe)/sqrt(1+tt(j).^2);
			t(ixe)=1000000.0 ./ (mirek(j-1) + (dit ./ (dit - djt)) * (mirek(j) - mirek(j-1)));
			ix(ixe)=false;
			end
		di(ix) = dj(ix); %#ok<AGROW>
		j=j+1;
		end

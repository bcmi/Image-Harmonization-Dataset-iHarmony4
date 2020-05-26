function varargout=dill(varargin)
%DILL Calculate arbitrary D-Illuminant.
%   Z=DILL(T,WL) returns arbitrary D illuminants based on specified
%   color temperatures T for the wavelengths WL. If T have size [M N ... P]
%   and WL is a row vector [1 W], Z will have size [M N ... P W].
%
%   The returned spectra are normalized to 100 at 560 nm.
%
%   If WL is omitted or empty, DWL is used for WL.
%
%   Example:
%      T=[5000 5500 6500]';
%      plot(dwl,dill(T));
%      xlabel('Wavelength(nm)'); ylabel('Emittance');
%      legend(num2str(T));
%
%   See also: DWL, BLACKBODY

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: dill.m 23 2007-01-28 22:55:34Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([-1 0 1 0],5,@i_dill,varargin{:});
	error(err);

function z=i_dill(T,wl)
	sz=size(T);
	if sz(2)==1; sz=sz(1);end
	
	lam=300:10:830;
	inrange=(wl>=lam(1) & wl<=lam(end));
	T=T(:);
	z=nan*zeros(size(T,1), size(wl,2));
	for i=1:length(T)
		d=doone(T(i));
		z(i,inrange)=interp1(lam,d,wl(inrange));
		end
	z=reshape(z,[sz length(wl)]);

function z=doone(T)
	persistent s
	if isempty(s)
		s=[ 0.04	0.02	0.00
			6.00	4.50	2.00
			29.6	22.4	4.0
			55.3	42.0	8.5
			57.30	40.60	7.80
			61.80	41.60	6.70
			61.50	38.00	5.30
			68.80	43.40	6.10
			63.40	38.50	3.00
			65.80	35.00	1.20
			94.80	43.40	-1.10
			104.80	46.30	-0.50
			105.90	43.90	-0.70
			96.80	37.10	-1.20
			113.90	36.70	-2.60
			125.60	35.90	-2.90
			125.50	32.60	-2.80
			121.30	27.90	-2.60
			121.30	24.30	-2.60
			113.50	20.10	-1.80
			113.10	16.20	-1.50
			110.80	13.20	-1.30
			106.50	8.60	-1.20
			108.80	6.10	-1.00
			105.30	4.20	-0.50
			104.40	1.90	-0.30
			100.00	0.00	0.00
			96.00	-1.60	0.20
			95.10	-3.50	0.50
			89.10	-3.50	2.10
			90.50	-5.80	3.20
			90.30	-7.20	4.10
			88.40	-8.60	4.70
			84.00	-9.50	5.10
			85.10	-10.90	6.70
			81.90	-10.70	7.30
			82.60	-12.00	8.60
			84.90	-14.00	9.80
			81.30	-13.60	10.20
			71.90	-12.00	8.30
			74.30	-13.30	9.60
			76.40	-12.90	8.50
			63.30	-10.60	7.00
			71.70	-11.60	7.60
			77.00	-12.20	8.00
			65.20	-10.20	6.70
			47.70	-7.80	5.20
			68.60	-11.20	7.40
			65.00	-10.40	6.80
			66.00	-10.60	7.00
			61.00	-9.70	6.40
			53.30	-8.30	5.50
			58.90	-9.30	6.10
			61.90	-9.80	6.50
			];
		end
	iT=1./T;
	if T<=7000
		xx=((-4.607e9*iT+2.9678e6)*iT+.09911e3)*iT+0.244063;
	else
		xx=((-2.0064e9*iT+1.9018e6)*iT+247.48)*iT+0.237040;
		end
	yy=(-3.000*xx+2.870)*xx-0.275;
	den=0.0241+0.2562*xx-0.7341*yy;
	m1=(-1.3515-1.7703*xx+5.9114*yy)/den;
	m2=(0.0300-31.4424*xx+30.0717*yy)/den;
	z=s*[1;m1;m2];

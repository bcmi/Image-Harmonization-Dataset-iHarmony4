function varargout=blackbody(varargin)
%BLACKBODY Calculate radiation from a Planck black body radiator.
%   Z=BLACKBODY(T,WL) returns the blackbody
%   radiation spectra at wavelengths WL for given temperatures T. T have
%   size [M N ... P] and WL is a row vector [1 W]. Z will then have 
%   size [M N ... P W]. If WL is empty or omitted, DWL is be used for WL.
%
%   The returned spectra are normalized to 100 at 560 nm.
%
%   Example:
%      lam=380:10:720;
%      T=[5000 5500 6500]';
%      plot(lam,blackbody(T,lam));
%      xlabel('Wavelength(nm)'); ylabel('Emittance');
%      legend(num2str(T));
%
%   See also DILL

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: blackbody.m 23 2007-01-28 22:55:34Z jerkerw $

	[err,varargout{1:max(1,nargout)}]=optproc([-1 0 1 0],5,@i_blackbody,varargin{:});
	error(err);

function z=i_blackbody(T,wl)
	sz=size(T);
	if sz(2)==1; sz=sz(1);end
	T=T(:);
	wl=wl(:);
	c1=3.741832E-16;
	c2=0.01438786;
	wl560=560e-9;
	wl=wl*1e-9;
	m560=c1./(wl560^5*(exp(c2./(T.*wl560))-1));
	[mwl,mT]=meshgrid(wl,T);
	z =100./m560(:,ones(1,length(wl)))*c1./(mwl.^5.*(exp(c2./(mT.*mwl))-1));
	z=reshape(z,[sz length(wl)]);

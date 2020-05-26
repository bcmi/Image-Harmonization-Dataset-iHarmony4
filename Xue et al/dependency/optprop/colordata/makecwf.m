function z=makecwf(varargin)
%MAKECWF Create color weighting function.
%   Z=MAKECWF(ILLOBS,WL), where ILLOBS is a char vector holding an
%   illuminant and observer specification of the form ILL/OBS and WL is a
%   wavelength range, returns a struct with the following fields:
%
%   Fieldname       Class         Example
%   --------------  ------------  ------------------------------------------------
%   name            char vector   'ASTM D50/2 Table 6'
%   whitepoint      [1x3 double]  96.4220 100 82.5210]
%   weights         [Nx3 double]  [0.0700 0.0020 0.3350; 0.1910 0.0050 0.9060;...]
%   wl              [1xN double]  [400 410 420 ... 700];
%   docompensation  logical       0
%   illuminant      char vector   'D50'
%   observer        char vector   '2'
%
%   ...=MAKECWF(...,'ASTM', SW), where SW is one of 'off', 'first' or
%   'only', tries to make CWF from ASTM tables before calculating them,
%   according to SW setting.
%

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: makecwf.m 23 2007-01-28 22:55:34Z jerkerw $

	cwf=[];
	wl=[];
	base=1;
	if 1<=nargin
		if iscwf(varargin{1})
			if isstruct(varargin)
				error(illpar('First argument must be a char representation of a CWF, e.g. ''D50/2''.)'));
			else
				cwf=varargin{1};
				base=2;
				end
			end
		if base<=nargin && iswlrange(varargin{2})
			wl=varargin{2};
			base=3;
			end
		end
	cwf=optgetpref('cwf', cwf);
	wl=optgetpref('WLRange', wl);
	if base<=nargin && ~ischar(varargin{base})
		error(illpar('Name of named argument must be char array'));
		end
	Default=struct( ...
		  'ASTM', optgetpref('ASTM') ...
		  ,'SpectrumType', optgetpref('SpectrumType') ...
		  );
	par=args2struct(Default,varargin(base:end));
	par.ASTM=partialmatch(par.ASTM, {'off', 'first', 'only'});
	par.SpectrumType=partialmatch(par.SpectrumType, {'compensated', 'uncompensated'});
	
	if ~strcmp(par.ASTM, 'off')
		[err,z]=tryastm(cwf,wl,par.SpectrumType);
		if ~isempty(err) && ~strcmp(par.ASTM, 'only')
			[err,z]=trycalc(cwf,wl,par.SpectrumType);
			end
	elseif ~strcmp(optgetpref('astm'), 'only')
		[err,z]=trycalc(cwf,wl,par.SpectrumType);
		end
	if ~isempty(err)
		error(err);
		end
	z.illuminant=cwf2ill(cwf);
	z.observer=cwf2obs(cwf);


function [err,cwf]=tryastm(wanted,wl,comp)
	cwf=astm('cwf',wanted,wl,comp);
	if isempty(cwf)
		if any(strcmp(upper(strrep(wanted,'/','_')),fieldnames(astm('cwf'))))
			err=illpar('Can not find an ASTM table for this wavelength range');
		else
			err=illpar('Can not find ASTM color weighting function for  %s.', wanted);
			end
	else
		err=[];
		cwf.weights=AdjustTable(cwf.weights,cwf.wl,wl);
		cwf.wl=wl;
		cwf.docompensation=false;
		end

function [err,z]=trycalc(wanted,wl,comp)
	[obs,wlobs]=observer(wanted);
	if isempty(obs);err=illpar('No such observer: ''%s''.', cwf2obs(wanted));return;end
	ill=illuminant(wanted,wlobs);
	if isempty(ill);err=illpar('No such illuminant: ''%s''.', cwf2ill(wanted));return;end
	z.name=['Calculated ' wanted];
	weights=100*(obs.*ill([1 1 1],:)'./(ill*obs(:,2)));
	%
	% Planning to calculate a weighting function for the given wavelength
	% range according to ASTM
	%
	z.whitepoint=sum(weights);
	z.whitepoint=z.whitepoint;
	z.weights=weights;
	z.wl=wlobs;
	z.docompensation=strcmp(comp,'uncompensated');
	err=[];

function z=AdjustTable(cwf,lam,wl)
	% Adjust the CWF cwf so that it is added from the beginning and end to
	% match the requested wavelength range wl, or expanded with zeros if
	% it's too big
	
	lenlam=length(lam);
	dw=wl(2)-wl(1);
	ixs=(wl(1)-lam(1))/dw+1;
	ixe=lenlam-(lam(end)-wl(end))/dw;
	% Add the CWF up and return
	z=[
		zeros(1-ixs,3);
		sum(cwf(1:max(1,ixs),:),1)
		cwf(max(1,ixs)+1:min(end,ixe)-1,:)
		sum(cwf(min(end,ixe):end,:),1);
		zeros(max(lenlam,ixe)-lenlam,3);
		];

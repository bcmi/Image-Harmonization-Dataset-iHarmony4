function z=concmix(Hues,n, varargin)
%CONCMIX Generate saturation/value map of hues.
%
%   CONCMIX(HUES,NS), where HUES is a NHxNC matrix and N is scalar,
%   generates a color map of size (2*NS-1)xNHxNC. For each hue in HUES an
%   interpolation is performed beginning with one down to the hue value in
%   NS steps. Then all colors/inks are interpolated down to zero in n-1
%   steps. This means that the first row in every NC matrix are all ones
%   and last rows are all zeros.
%
%   CONCMIX(...,'Range', 'full') returns previous matrix.
%   CONCMIX(...,'Range', 'upper') returns a NSxNHxNC matrix interpolated
%      from one down to each hue.
%   CONCMIX(...,'Range', 'lower') returns a NSxNHxNC matrix interpolated
%      from each hue down to zero.
%
%   CONCMIX(...,'Mode', 'add') interpolates linearly, suitable for additive
%      color mixing.
%   CONCMIX(...,'Mode', 'sub') interpolates logarithmically using
%      LOGCOLS(START,END,.005,N), suitable for subtractive mixing to get an
%      even distribution in Lab space.
%   CONCMIX(...,'Mode',FN) with string or function handle FN, calls FN to do
%      the interpolation between two concentrations. FN should be declared
%      FN(BEG,END,N) where BEG and END is a vector containing the start and
%      end points respectively and N is the number points that should be
%      interpolated. Each column in BEG and END is to be interpolated
%      independently. If N=2, [BEG;END] should be returned.
%
%   Example:
%      Generate a RGB test chart with 19x30 = (2*10-1)x(2*5*3) patches and
%      display it
%
%         rgb=concmix(colormix(5),10);
%         image(rgb);
%         axis image;
%
%      Generate a CBMRYG test chart with 19x60x6 patches
%         cbmryg=concmix(colormix(5,6),10);
%
%   See also COLORMIX, SUBMIX

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: concmix.m 23 2007-01-28 22:55:34Z jerkerw $


	Defaults = struct( ...
		  'Range', 'full' ...
		, 'Mode', 'add' ...
		);
	par = args2struct(Defaults, varargin);
	switch par.Range %#ok<ALIGN>
		case 'full'
			MixLength=2*n-1;
			LowerRange = n:2*n-1;
		case 'upper'
			MixLength = n;
		case 'lower'
			MixLength = n;
			LowerRange = 1:n;
		otherwise
			error([mfilename, ': Unknown Range'])
    	end
	if ischar(par.Mode)
		switch lower(par.Mode)
			case 'add'
				MixFcn=@lincols;
			case 'sub'
				MixFcn=@pow3cols;
			otherwise
				MixFcn=par.Mode;
			end
	else
		MixFcn=par.Mode;
		end	
	[NumInks, NumChannels] = size(Hues);
	Hues=Hues(:)';
	z = zeros(MixLength,NumInks*NumChannels);
	% First go from all ones down to hue in n steps
	if ~strcmp(par.Range, 'lower')
 		z(1:n,:)=MixFcn(ones(1,NumInks*NumChannels), Hues, n);
		end
	if ~strcmp(par.Range, 'upper')
	    % We start by overwriting the previous last, thereby getting a continous series
		z(LowerRange,:)=MixFcn(Hues, zeros(1,NumInks*NumChannels), n);
		end
	z(isnear(z,0))=0;
	z(isnear(z,1))=1;
	% Start with ones on top
	z=reshape(z,[],NumInks,NumChannels);

function z = pow3cols(d1, d2, n)
% 	z=powcols(d1,d2,3,n);
	z=logcols(d1,d2,.005,n);


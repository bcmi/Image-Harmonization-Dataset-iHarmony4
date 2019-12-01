function z=colormix(ns,nc,p)
%COLORMIX Mix primary RGB or CMY... colors/inks.
%
%   COLORMIX(NS,NC) generates an (2*NS)xNC matrix of color data in range [0,1].
%   COLORMIX mixes each pair out of the NC colors in NS steps.
%
%   COLORMIX(NS) is the same as COLORMIX(NS, 3)
%
%   COLORMIX(NS,NC,P) with scalar P uses a power function to interpolate
%   the NS steps between two hues. Recommended is to use P=1 for additive
%   mixing and P=2 for subtractive mixing.
%
%   COLORMIX(NS,NC,S) with string S='add' uses P=1, S='sub' uses P=2.
%
%   COLORMIX(NS,NC,FN) with string or function handle FN, calls FN to to
%   the interpolation between two hues. FN should be declared FN(BEG,END,N)
%   where BEG and END is a vector containing the start and end points
%   respectively and N is the number points that should be interpolated.
%   Each column in BEG and END is to be interpolated independently. If N=2,
%   [BEG;END] should be returned.
%
%   COLORMIX(1) is the same as MATLAB's colormap HSV(6).
%
%   Example:
%      Generate an image with 8 hues between each primary/secondary hue,
%      i.e. start with red and then interpolate 8 hues until yellow and
%      then 8 more until green etc.
%
%         rgb=colormix(8);
%         image(shiftdim(rgb,-1));
%
%      Generate hexachrome CBMRYG hue map for use with subtractive mixing
%      with two steps between each primary/secondary hue.
% 
%         cbmryg=colormix(2,6,2)
%
%   See also CONCMIX, HSV

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: colormix.m 23 2007-01-28 22:55:34Z jerkerw $


	if nargin < 3; p=1;end
	if nargin < 2; nc = 3; end
	if nargin < 1; ns = 1; end

	if ischar(p)
		switch lower(p)
			case 'add'
				p=1;
			case 'sub'
				p=2;
			end
		end	
	% Create Map for fully saturated mixes
	MixMap=zeros(2*nc+2,nc);
	MixMap(1:2:2*nc-1,:)=eye(nc);
	MixMap(2:2:2*nc,:)=eye(nc)+diag(ones(1,nc-1),1)+[zeros(nc-1,nc);[1 zeros(1,nc-1)]];
	MixMap(2*nc+(1:2),:)=MixMap(1:2,:);

	% Interpolate between each row in MixMap to create intervening colors 
	for i = 1:size(MixMap,1)-2
		if isnumeric(p)
			s=powcols(MixMap(i,:), MixMap(i+1,:),p,ns+1);
		else
			s=p(MixMap(i,:), MixMap(i+1,:),ns+1);
			end
		z(ns*(i-1)+(1:ns),:)=s(1:ns,:);
		end

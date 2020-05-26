function z=submix(ConcSteps, ColSteps, Range, Inks, ColFcn, ConcFcn)
%SUBMIX Generate color test map for subtractive mixings.
%
%   SUBMIX(NC,NH) generates a (2*NC-1) x 6*NH x 3 matrix with CMY values
%   suitable for test purposes. The distances between printed patches
%   mostly have an even distribution in Lab space. The map includes both
%   white and black.
%
%   SUBMIX(NC,NH,RNG) with string RNG={'lower'|'upper'} returns a 
%   NC x 6*NH x 3 matrix containing the lower or upper part of the map.
%   Default is RNG='full'.
%
%   SUBMIX(NH,NC,RNG,NI) return a matrix with the last dimension equal to NI.
%   Use this to generate test maps for printer with more than three inks.
%
%   SUBMIX(...,COLFCN,CONCFCN) uses COLFCN and CONCFCN to interpolate between
%   hues and concentrations respectively. See COLORMIX and CONCMIX.
%
%   Example:
%      cmy=submix(10,5);
%      image(cmy);        % This does not look good on screen since it uses rgb!
%
%   See also ADDMIX, COLORMIX, CONCMIX

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: submix.m 23 2007-01-28 22:55:34Z jerkerw $


	if nargin < 6 || isempty(ConcFcn);		ConcFcn='sub'	; end
	if nargin < 5 || isempty(ColFcn);		ColFcn='sub'	; end
	if nargin < 4 || isempty(Inks);			Inks=3			; end
	if nargin < 3 || isempty(Range);		Range='full'	; end
	if nargin < 2 || isempty(ColSteps);		ColSteps=10		; end
	if nargin < 1 || isempty(ConcSteps);	ConcSteps=20	; end

	% Switch the meaning of upper and lower since we are assuming
	% subtractive mixing

	switch lower(Range)
		case 'lower'
			Range = 'upper';
		case 'upper'
			Range = 'lower';
		end

	% Get the hues
	hues=colormix(ColSteps,Inks, ColFcn);
	% Flip the result to get white on top
	z=flipdim(concmix(hues, ConcSteps, 'Range', Range, 'Mode', ConcFcn), 1);

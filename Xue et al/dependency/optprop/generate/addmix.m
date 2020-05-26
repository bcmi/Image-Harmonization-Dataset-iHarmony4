function varargout=addmix(ConcSteps, ColSteps, Range, Primaries, ColFcn, ConcFcn)
%ADDMIX Generate color test map for additive mixings.
%
%   ADDMIX(NC,NH) generates a (2*NC-1) x 6*NH x 3 matrix with RGB values
%   suitable for test purposes. The distances between patches mostly have
%   an even distribution in Lab space. The map includes both white and
%   black.
%
%   ADDMIX(NC,NH,RNG) with string RNG={'lower'|'upper'} returns a 
%   NC x 6*NH x 3 matrix containing the lower or upper part of the map.
%   Default is RNG='full'.
%
%   ADDMIX(NC,NH,RNG,NI) return a matrix with the last dimension equal to NI.
%   Use this to generate test maps for printer with more than three inks.
%
%   ADDMIX(...,COLFCN,CONCFCN) uses COLFCN and CONCFCN to interpolate between
%   hues and concentrations respectively. See COLORMIX and CONCMIX.
%
%   Example:
%      rgb=addmix(10,5);
%      image(rgb);
%
%   See also SUBMIX, COLORMIX, CONCMIX

% Part of the OptProp toolbox, $Version: 2.1 $
% Author: Jerker Wågberg, More Research & DPC, Sweden
% Email:  ['jerker.wagberg' char(64) 'more.se']

% $Id: addmix.m 23 2007-01-28 22:55:34Z jerkerw $

	if nargin < 6 || isempty(ConcFcn);		ConcFcn='add'	; end
	if nargin < 5 || isempty(ColFcn);		ColFcn='add'	; end
	if nargin < 4 || isempty(Primaries);	Primaries=3		; end
	if nargin < 3 || isempty(Range);		Range='full'	; end
	if nargin < 2 || isempty(ColSteps);		ColSteps=10		; end
	if nargin < 1 || isempty(ConcSteps);	ConcSteps=20	; end

	% Get the hues
	hues=colormix(ColSteps,Primaries, ColFcn);
	% Flip the result to get white on top
	z=concmix(hues, ConcSteps, 'Range', Range, 'Mode', ConcFcn);
	sz=size(z);
	varargout = MultiArgOut(nargout,reshape(z,[],sz(end)),sz(1:end-1));

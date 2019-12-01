function [err, argout, inshape, varargout] = MultiArgIn(dims, varargin)
%MULTIARGIN Normalize multidimensional input down to an array with two dimensions.
%   All input parameters up to the first string parameter are concatenated up to the last
%   plus one dimension of the highest order parameter. The dimensions of the less dimensional
%   parameters must be equal from the start of higher dimensional parameters.
%
% See also MULTIARGOUT

% The output can have a different layout as the input: e.g. LAB=XYZ2LAB(X,Y,Z), which will
% return LAB as a ND matrix with SIZE(LAB) == [SIZE(X) 3]. As a special case, if the all the
% dimensions between the first and last in LAB is one, the ND-array is reduced to a 2D array.

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: MultiArgIn.m 23 2007-01-28 22:55:34Z jerkerw $

	err=[];
	argout=[];
	inshape=[];
	if nargout >=4; varargout=repmat({{}},1,nargout-3); end
	if length(varargin) < 1
		err=IllPar('Not enough input arguments.');
		return;
		end
	FirstClass=class(varargin{1});
	FirstSize = size(varargin{1});
	% Find index of first argument that differs.
	PossibleArgs=1;
	ix=2;
	while ix<=length(varargin)
		if     isa(varargin{ix}, FirstClass) ...
			&& isequal(size(varargin{ix}), FirstSize)
			PossibleArgs = PossibleArgs + 1;
		else
			break;
			end
		ix=ix+1;
		end

	if PossibleArgs >= dims
		NumArgs=dims;
	elseif FirstSize(end) == dims
		NumArgs=1;
	else
		if isempty(PossibleArgs)
			err=illpar('Wrong size of last dimension or not enough input arguments.');
		elseif length(varargin)>PossibleArgs ...
			&& isa(varargin{PossibleArgs}, FirstClass)
 			err=illpar('Input arguments'' dimensionality mismatch.');
		else
			err=illpar('Not enough input arguments or wrong dimension');
			end
		return
		end

	%
	
	sz=size(varargin{1});
	if NumArgs==1
		inshape=sz(1:end-1);
		argout=reshape(varargin{1}, [], sz(end));
	else
		inshape = iff(isvector(varargin{1}) && sz(2)==1, sz(1), sz);
		argout=reshape(cat(length(inshape)+1, varargin{1:NumArgs}),[],NumArgs);
		end

	% Copy the remaining arguments to the output arguments. If there are
	% fewer output arguments than input argument, the last output argument
	% will be a cell array, holding the input arguments that didn't have a
	% corresponding output argument. If there are more output arguments
	% than input arguments, the remaining output argument will keep their
	% initial value as empty cells.

	VarNargout=nargout-3;
	nargrest=length(varargin)-NumArgs;
	if VarNargout < nargrest
		if VarNargout == 0
			err=illpar('Too many input arguments.');
			return;
			end
		varargout(1:VarNargout-1)=varargin(NumArgs+(1:VarNargout-1));
		varargout{VarNargout}=varargin(NumArgs+VarNargout:end);
	elseif 0<nargrest
		varargout(1:nargrest)=varargin(NumArgs+1:end);
		end

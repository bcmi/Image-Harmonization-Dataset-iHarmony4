function z=xd(varargin)
%XD Permute dimensions temporarily or permanently.
%   Z=XD(FUN,X), where FUN is a function handle and X is
%   M-by-N-by-...-by-S-by-T, temporarily permutes the dimensions of X
%   to be M-by-N-by-...-by-T-by-S, calls FUN with this new X, and then
%   permutes the last two dimension of the output from FUN, making it an 
%   M-by-N-by-...-by-S-by-W. FUN is supposed to only change the last
%   dimension of its input.
%
%   Z=XD(FUN,X,A1,A2,...AN) calls FUN as FUN(Y,A1,A2,...,AN) with Y
%   being the temporarily permuted X.
%
%   Z=XD(DIM,FUN,X,...), where DIM is scalar, puts the dimension DIM last
%   in Y, before calling FUN.
%
%   Z=XD(X) assigns X to Z, with the last two dimensions swapped.
%
%   Z=XD(DIM,X) assigns X to Z with the last and DIM dimensions swapped.
%
%   Remark:
%      The conversion routines in OptProp demand that their input are
%      given with the colorimetric dimensions along the last dimension.
%      However, it is more natural to store e.g. a series of images in a
%      4-dimensional matrix, with RGB along the third dimension and an
%      image index along the fourth. By using XD, the routines in OptProp
%      can still be used quite conveniently, by using either the temporary
%      permutation together with a function handle or by converting to
%      OptProp format at the beginning of a session and then convert it
%      back at the end. XD is its own inverse, so XD(XD(X))==X.
%
%   Example:
%      Read all the, equally sized, images within QQ.TIF, convert them from
%      sRGB to ADOBE in one fell swoop, and write them to the new file
%      QNEW.TIF.
%
%      fun=@(x)imread('qq.tif',x);
%      n=length(imfinfo('qq.tif'));
%      im=arrayfun(fun,1:n,'uni',false);
%      im=cat(4,im{:});
%
%      im=xd(@rgb2rgb,im,'srgb','adobe');
% 
%      sz=size(im);
%      im=mat2cell(im,[sz(1),sz(2),sz(3),ones(1,n));
%      cellfun(@(x)imwrite(x,'qnew.tif','WriteMode','append'),im);
%

% Part of the OptProp toolbox, $Version: 2.1 $
% Author: Jerker Wågberg, More Research & DPC, Sweden
% Email:  ['jerker.wagberg' char(64) 'more.se']

% $Id: xd.m 23 2007-01-28 22:55:34Z jerkerw $

	error(nargchk(1,inf,nargin));
	dim=[];
	fun=[];
	args={};
	argbase=[];
	funfirst=isa(varargin{1}, 'function_handle');

	switch nargin
		case 1
			if funfirst
				error(illpar('Illegal argument list'));
			else
				data=varargin{1};
				end
		case 2
			if funfirst
				[fun data]=varargin{1:2};
			else
				[dim data]=varargin{1:2};
				end
		case 3
			if funfirst
				[fun data]=varargin{1:2};
				argbase=3;
			else
				[dim fun data]=varargin{1:3};
				end
		otherwise
			if funfirst
				[fun data]=varargin{1:2};
				argbase=3;
			else
				[dim fun data]=varargin{1:3};
				argbase=4;
				end
		end

	if isempty(dim)
		dim=ndims(data)+[-1 0];
		end;

	dim=dim(:)';
	if     ~isnumeric(dim) ...
		|| 2 < numel(dim) ...
		|| any(ndims(data)<dim) ...
		|| any(floor(dim)~=dim) ...
		|| any(dim<0)
		error(illpar('Not a valid dimension specifier'));
		end
	if isscalar(dim)
		dim=[dim ndims(data)];
		end
	if ~isempty(argbase)
		args=varargin(argbase:end);
		end
	perm=1:ndims(data);
	perm(dim)=dim([2 1]);
	if isempty(fun)
		z=permute(data,perm);
	else
		z=ipermute(fun(permute(data,perm),args{:}),perm);
		end

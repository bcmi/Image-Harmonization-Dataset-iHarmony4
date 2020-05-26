function varargout=closesurf(varargin)
%CLOSESURF Close a parameterized surface by concatenation.
%   CLOSESURF closes a surface by concatenating the first row or column
%   after the last row/column. The surface must be "closable", i.e. the
%   first and the last row or column must be constant. SURFVOL will close
%   the surface by concatenating the surface with items from the first
%   column or, if the columns are constant, concatenate the rows with items
%   from the first row.
%
%   Example:
%      [r,g,b]=addmix(4,4);
%      subplot(121)
%      surf(r,g,b,cat(3,r,g,b));
%      axis equal;shading interp;view(75,20);
%      [r,b,g]=closesurf(r,g,b);
%      subplot(122);
%      surf(r,g,b,cat(3,r,g,b));
%      axis equal;shading interp;view(75,20);

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: closesurf.m 46 2007-03-28 08:52:17Z jerkerw $


 	[err,xyz,InShape, Params]=MultiArgIn(3, varargin{:});
	error(err);
	if length(InShape) ~= 2
		error([mfilename ': Surfaces must be specified as (MxN,MxN,MxN) or (MxNx3)']);
		end
	Defaults=struct('Aux', []);
	par=args2struct(Defaults,Params);
	xyz=reshape(xyz,[InShape 3]);
	if ~isempty(par.Aux) && any(size(xyz)~=size(par.Aux))
		error([mfilename ': Auxilliary matrix must have same size as primary']);
		end
	if isconst(xyz,1,2)
		xyz=cat(2,xyz,xyz(:,1,:));
		if ~isempty(par.Aux)
			par.Aux=cat(2,par.Aux,par.Aux(:,1,:));
			end
		InShape(2)=InShape(2)+1;
	elseif isconst(xyz,2,1)
		xyz=cat(1,xyz,xyz(1,:,:));
		if ~isempty(par.Aux)
			par.Aux=cat(1,par.Aux,par.Aux(1,:,:));
			end
		InShape(1)=InShape(1)+1;
	elseif ~(isconst(xyz,1,1) && isconst(xyz,2,2))
		warning('optprop:noclose', 'Surface can not be closed.');
		xyz=cat(2,xyz,xyz(:,1,:));
		if ~isempty(par.Aux)
			par.Aux=cat(2,par.Aux,par.Aux(:,1,:));
			end
		InShape(2)=InShape(2)+1;
		end
	if isempty(par.Aux)
		varargout = MultiArgOut(nargout,reshape(xyz,[],3),InShape);
	else
		varargout(1:nargout-1) = MultiArgOut(nargout-1,reshape(xyz,[],3),InShape);
		varargout(nargout) = MultiArgOut(1,reshape(par.Aux,[],3),InShape);
		end

function z=isconst(xyz,dim,odim)
	d={':',':',':'};
	d{dim}=[1 size(xyz,dim)];
	z=~any(any(any(abs(diff(xyz(d{:}),1,odim))>10000*eps)),3);

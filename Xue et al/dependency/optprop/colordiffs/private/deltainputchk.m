function [err,lab1,is1,lab2,is2,type,klch,gotstandard]=deltainputchk(vargin)
%DELTAINPUTCHK Check arguments for delta functions

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: deltainputchk.m 23 2007-01-28 22:55:34Z jerkerw $

	[err,lab1,is1,lab2,is2,type,klch,gotstandard]=deal([]);
	type='single';
	typeset=false;
	%
	% Do we have a type specifier ?
	%
	fun=@(x)ischar(x)&&ischar(partialmatch(x,{'single', 'all'},'noerr'));
	ix=find(cellfun(fun,vargin),1);
	if ~isempty(ix)
		type=vargin{ix};
		vargin(ix)=[];
		typeset=true;
		end
	[posargs,pv]=parseparams(vargin);
	err=nargchk(1,2,length(posargs),'struct');
	if ~isempty(err);return;end
	
	% Set pv args
	Default=struct('GotStandard', true, 'KLCH', [1 1 1]);
	[par,err]=args2struct(Default,pv,false);
	if ~isempty(err);return;end
	klch=par.KLCH;
	if ~isvector(klch) || length(klch)~=3
		err=illpar('KLCH must be a 3-element vector');
		return
		end
	gotstandard=par.GotStandard;

	%
	% Single input implies 'all'. If two inputs and 'all', the last dim
	% must conform. If 'single', all dims must be equal
	%
	
	lab1=posargs{1};
	if length(posargs) == 1
		if typeset && strcmp(type, 'single')
			err=illpar('Can not specify ''single'' together with just one matrix argument');
			return;
			end
		lab2 = lab1;
		type='all';
	else
		lab2=posargs{2};
		if strcmp(type,'all') && size(lab1,ndims(lab1)) ~= size(lab2,ndims(lab2))
			err=illpar('The size of each individual last dimension must be equal');
			return;
		elseif strcmp(type,'single') && size(lab1,1)~=1 && size(lab2,1)~=1 && ~isequal(size(lab1),size(lab2))
			err=illpar('Matrices must have same size.');
			return;
			end
		end

	[err,lab1,is1]=MultiArgIn(1, lab1);
	if ~isempty(err);return;end
	[err,lab2,is2]=MultiArgIn(1, lab2);

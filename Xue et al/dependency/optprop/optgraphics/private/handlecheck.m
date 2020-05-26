function [h,args] = handlecheck(hspec,varargin)
%HANDLECHECK Check if the first argument is handle.

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: handlecheck.m 23 2007-01-28 22:55:34Z jerkerw $

	h=[];
	args=varargin;
	for i=1:numel(hspec)/2;
		[h,args]=checkone(hspec{i+(0:1)},varargin);
		if ~isempty(h)
			return;
			end
		end

function [h,args]=checkone(pvname,type,vargin)
	h=[];
	if numel(vargin)>0 ...
		&& numel(vargin{1})==1 ...
		&& ishandle(vargin{1}) ...
		&& strcmp(get(vargin{1}, 'type'),type)
		h=vargin{1};
		vargin=vargin(2:end);
		end
	if numel(vargin)>0
		ix=find(strcmpi(pvname,vargin));
		ix=unique([ix ix+1]);
		ix(ix>=numel(vargin))=[];
		ix=ix+1;
		ix=ix(cellfun(@(x)numel(x)==1 && ishandle(x) && strcmpi(type,get(x,'type')),vargin(ix)));
		if ~isempty(ix)
			h=vargin{ix(end)};
			vargin=vargin([1:ix(end)-2 ix(end)+1:end]);
			end
		end
	args=vargin;
	

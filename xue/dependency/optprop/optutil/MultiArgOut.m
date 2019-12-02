function ArgOut=MultiArgOut(ArgsOut, x, InShape, LastIndex)
%MULTIARGOUT Resize and distribute multidimensional data.
%
%   See also MULTIARGIN

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: MultiArgOut.m 23 2007-01-28 22:55:34Z jerkerw $

	if nargin < 4; LastIndex = size(x,2); end
	if nargin < 3; InShape = size(x,1); end

	ArgOut=cell(1,max([1 ArgsOut]));
	if ArgsOut<=1
		ArgOut{1} = reshape(x,[InShape LastIndex]);
	else
		if length(InShape) < 2
			InShape = [InShape 1];
			end
		for i=1:ArgsOut
			ArgOut{i}=reshape(x(:,i),InShape);
			end
		end

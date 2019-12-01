function z=surfvol(varargin)
%SURFVOL returns the volume of parameterized volume XYZ
%   Called as SURFVOL(XYZ) with size(XYZ)=MxNx3 or
%   SURFVOL(X,Y,Z) with X, Y and Z having size MxN.
%
%   The surface must be "closable", i.e. the first and the last row or
%   column must be constant. SURFVOL will close the surface by concate-
%   nating the surface with items from the first column or, if the columns
%   are constant, concatenate the rows with items from the first row.
%
%   Example:
%      Calculate the approximate volume of a unit sphere:
%         [x,y,z]=sphere;
%         surfvol(x,y,z)
%
%   See also CLOSESURF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: surfvol.m 46 2007-03-28 08:52:17Z jerkerw $

	[err,xyz,InShape,iParms]=MultiArgIn(3, varargin{:});
	error(err);
	if length(InShape)<2
		error(illpar('Input must be 3D or more'));
		end
	if InShape==2
		InShape=[InShape 1];
		end
	xyz=xd(reshape(xyz,[InShape(1:2) prod(InShape(3:end)) 3]));
	OutShape=[InShape(3:end) 1];
	z=zeros(OutShape);
	for i=1:numel(z)
		z(i)=i_surfvol(xyz(:,:,:,i));
		end

function z=i_surfvol(xyz)
	xyz=closesurf(xyz);
	c1=xyz(1:end-1,2:end,:);
	c2=xyz(2:end,1:end-1,:);
	% Find a non nan point on the surface
	[m,n]=find(~any(isnan(xyz),3));
	if isempty(m)
		z = nan;
	else
		Center=repmat(xyz(m(1),n(1),:),size(xyz,1)-1,size(xyz,2)-1);
		b=xyz(1:end-1,1:end-1,:);
		z1=dot(cross(c1-b, c2-b, 3), Center-b, 3);

		b=xyz(2:end,2:end,:);
		z2=dot(cross(c2-b, c1-b, 3), Center-b,3);

		z=abs(sum(nansum1(z1)+nansum1(z2)))/6;
		end

function z=nansum1(x)
	x(isnan(x))=0;
	z=sum(x,1);

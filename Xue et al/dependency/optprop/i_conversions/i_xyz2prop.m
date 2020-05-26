function props=i_xyz2prop(XYZ,Prop,IllObs)
%I_XYZ2PROP Convert from tristimulus XYZ to various optical properties.
%
%   A=I_XYZ2PROP(XYZ, PROPS, CWF), where size(XYZ)=[M N ... O 3],
%   char array PROPS size [1 P], returns matrix A with size [M N ... O P].  
%
%   PROPS can be any one of 'LabWTJXYZxy' and/or any of 'Rx','Ry','Rz'.
%   These specifiers are case sensitive. PROPLEN is the number of speci-
%   fiers in PROPS, where 'Rx', 'Ry' and 'Rz' counts as one specifier.
%   
%      L  CIE L*          W  CIE Whiteness
%      a  CIE a*          T  CIE Tint
%      b  CIE b*          J  Yellowness
%      X  CIE X           Rx
%      Y  CIE Y           Ry
%      Z  CIE Z           Rz
%
%   CWF is a color weighting function specification. It can be a string,
%   e.g. 'D50/2', or a struct, see MAKECWF. If empty, the default cwf,
%   OPTGETPREF('cwf') is used.
%
%   Remark:
%      This is a low level function, that has a rigid parameter passing
%      mechanism and no error handling. It is only to be used when the
%      need for speed is imperative. In all other cases,
%      use XYZ2PROP instead.
%
% Example:
%      Get the Lab and CIE Whiteness of the D65/10 whitepoint under D65/2
%      into a [1 4] row vector:
%
%         z=i_xyz2prop(wpt('D65/10'),'LabW','D65/2')
%
%   See also: XYZ2PROP,MAKECWF,OPTGETPREF

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: i_xyz2prop.m 44 2007-02-14 12:50:26Z jerkerw $

	Prop=PropExchange(Prop,'RxRyRz', 'åäö');
	n=size(XYZ,1);
	PropMap='XYZxyLabWTJåäö';
	if ~all(ismember(Prop, PropMap))
		error(['Unknown optical property spec: ' Prop]);
		end
	if isempty(Prop)
		props=zeros(size(XYZ,1),0);
	else
		Val=zeros(size(XYZ,1),14);
		% Find where we should put the data. Can handle double entries.
		[propix,ix]=find(PropMap(ones(size(Prop,2),1),:)==Prop(ones(size(PropMap,2),1),:)');
		if any(ix<=3)
			Val(:,1:3)=XYZ;
			end
		if any(4<=ix & ix<=5)
			Val(:,4:5)=i_xyz2xy(XYZ);
			end
		if any(6<=ix & ix<=8)
			Val(:,6:8)=i_xyz2lab(XYZ,IllObs);
			end
		if any(9<=ix & ix<=11)
			Val(:,9:11)=i_xyz2wtj(XYZ,IllObs);
			end
		if any(12<=ix & ix <=14)
			Val(:,12:14)=i_xyz2rxryrz(XYZ, IllObs);
			end
		[propix,ixx]=sort(propix);
		ix=ix(ixx);
		props=Val(:,ix(propix));
		end

function varargout=de2000(varargin)
%DE2000 Calculate DeltaE(2000).
%   DE2000 calculates the DeltaE 2000 values between two set of samples.
%
%   DE2000(LAB) returns a symmetrical matrix of DE2000 values of all pairs
%   of LAB
%
%   Z=DE2000(LAB1,LAB2) or Z=DE2000(LAB1,LAB2,'single') where LAB1 and LAB2
%   both have size [M N ... T 3] returns Z with size [M N ... T] where each
%   value in LAB1 have been compared to corresponding value in LAB2. LAB1
%   or LAB2 can also have size [1 3] in which case it is expanded to same
%   size as the other.
%
%	Z=DE2000(LAB1,LAB2,'all') with SIZE(LAB1)=[M N ... Q S 3]
%   and SIZE(LAB2)=[M N ... Q T 3], returns Z with size(Z)=[M N O ... S T];
%
%   Z=DE2000(..., 'KLCH', LCH), where LCH is a 1-by-3 vector, uses these
%   values as KL, KC and KH instead of the default LCH=[1 1 1]
%
%   Example:
%      Show the error in DE2000 introduced by chromatic adaptation of Lab
%      values compared to proper calculation from spectra
%
%         r=colorchecker;
%         rgb=roo2disp(r);
%         labD65=roo2lab(r,'D65/10');
%         labA=roo2lab(r,'A/10');
%         labD65toA=lab2lab(labD65,'D65/10','A/10');
%         D2000=de2000(labA,labD65toA);
%         hb=bar3c(D2000,rgb);
%         zlabel('DE2000');
%
%   See also DE, DE94

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: de2000.m 24 2007-01-28 23:20:35Z jerkerw $

	function z=i_de2000(Lab)
		% deltaE00: Calculates the CIE Delta E00 Color Difference
		% Lawrence Taplin 08Jan01

		% Lab is an Mx6 where lab is in (:,1:3) and reflab in (:,4:6)
		% We're do it this way to take advantage of OPTPROC's chunking
		Lab=reshape(Lab,[],3,2);
		%CIELAB Chroma
		C = sqrt(Lab(:,2,:).^2+Lab(:,3,:).^2);

		%Lab Prime
		mC = mean(C,3);
		G=0.5*(1-sqrt((mC.^7)./((mC.^7)+(25.^7))));
		LabP=cat(2,Lab(:,1,:),Lab(:,2,:).*(1+repmat(G,[1 1 2])), Lab(:,3,:));
		%Chroma
		CP = sqrt(LabP(:,2,:).^2+LabP(:,3,:).^2);
		%Hue Angle
		hPt = atan2Deg(LabP(:,3,:),LabP(:,2,:));
		%Add in 360 to the smaller hue angle if absolute value of difference is > 180
		df=diff(hPt,1,3);
		ismin=cat(3,df<0,df>0);
		GT180=repmat(abs(df)>180,[1 1 2]);
		hP=hPt+360*(ismin & GT180);

		%Delta Values
		DLP = abs(diff(LabP(:,1,:),1,3));
		DCP = abs(diff(CP,1,3));
		DhP = abs(diff(hP,1,3));
		DHP = 2*(prod(CP,3)).^(1/2).*sind(DhP./2);

		%Arithmetic mean of LCh' values
		mLP = mean(LabP(:,1,:),3);
		mCP = mean(CP,3);
		mhP = mean(hP,3);
		%Weighting Functions
		SL = 1+(0.015.*(mLP-50).^2)./sqrt(20+(mLP-50).^2);
		SC = 1+0.045.*mCP;
		T = 1-0.17.*cosd(mhP-30)+0.24.*cosd(2.*mhP)+0.32.*cosd(3.*mhP+6)-0.2.*cosd(4.*mhP-63);
		SH = 1+0.015.*mCP.*T;
		%Rotation function
		RC = 2.*sqrt((mCP.^7)./((mCP.^7)+25.^7));
		DTheta = 30.*exp(-((mhP-275)./25).^2);
		RT = -sind(2.*DTheta).*RC;
		%Parametric factors
		kL = 1;
		kC = 1;
		kH = 1;

		z = ((DLP./kL./SL).^2+(DCP./kC./SC).^2+(DHP./kH./SH).^2+(RT.*(DCP./kC./SC).*(DHP./kH./SH))).^(1/2);
		end

	[err,lab1,is1,lab2,is2,mode]=deltainputchk(varargin);
	error(err);
	if strcmp(mode,'single')
		if size(lab1,1)==1
			inshape=is2;
			[err,delta]=optproc([1 0 0 0],[],@i_de2000,[lab1(ones(size(lab2,1),1),:) lab2]);
		elseif size(lab2,1)==1
			inshape=is1;
			[err,delta]=optproc([1 0 0 0],[],@i_de2000,[lab1 lab2(ones(size(lab1,1),1),:)]);
		else
			inshape=is1;
			[err,delta]=optproc([1 0 0 0],[],@i_de2000,[lab1 lab2]);
			end
	else
		inshape=[is1 is2];
		lab=[
			reshape(permute(repmat(lab1,[1 1 size(lab2,1)]),[1 3 2]),[],3) ...
			, reshape(permute(repmat(lab2,[1 1 size(lab2,1)]),[3 1 2]),[],3)
			];
		[err,delta]=optproc([1 0 0 0],[],@i_de2000,lab);	
		end
	error(err);
	varargout = MultiArgOut(nargout,delta,inshape,1);
	end

% ------------- define a convenient subfunctions -------------

function out = atan2Deg(inY,inX)
	out = atan2(inY,inX).*180./pi;
	out = out+(out<0).*360;
	end

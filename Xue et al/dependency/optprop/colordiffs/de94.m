function varargout=de94(varargin)
%DE94 Calculate DeltaE(94).
%DE94 calculates the DeltaE 94 values between two set of samples.
%
%   DE94(LAB) returns a symmetrical matrix of DE94 values of all pairs
%   of LAB.
%
%   Z=DE94(LAB1,REF) where LAB1 and REF both have size [M N ... T 3] returns Z
%   with size [M N ... T] where each value in LAB1 have been compared to
%   corresponding value in REF. LAB1 or REF can also have size [1 3] in which
%   case it is expanded to same size as the other. REF is considered as the
%   reference sample.
%
%	Z=DE94(LAB1,REF,'all') with SIZE(LAB1)=[M N ... Q S 3]
%   and SIZE(REF)=[M N ... Q T 3], returns Z with size(Z)=[M N O ... S T];
%
%   Z=DE94(..., 'KLCH', LCH), where LCH is a 1-by-3 vector, uses these
%   values as KL, KC and KH instead of the default LCH=[1 1 1]
%
%   Z=DE94(..., 'GotStandard', ONOFF), where ONOFF is a logical scalar,
%   specifying whether REF should be considered as a standard. Default is
%   true.
%
%   Example:
%      Show the error in DE94 introduced by chromatic adaptation of Lab
%      values compared to proper calculation from spectra
%
%         r=colorchecker;
%         rgb=roo2disp(r);
%         labD65=roo2lab(r,'D65/10');
%         labA=roo2lab(r,'A/10');
%         labD65toA=lab2lab(labD65,'D65/10','A/10');
%         D94=de94(labA,labD65toA);
%         hb=bar3c(D94,rgb);
%         zlabel('DE94');
%
%   See also DE, DE2000

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: de94.m 29 2007-01-29 22:21:48Z jerkerw $


	function z=i_de94(Lab)
		% Lab is an Mx6 where lab is in (:,1:3) and reflab in (:,4:6)
		Lab=reshape(Lab,[],3,2);
		C=sqrt(sum(Lab(:,[2 3],:).^2,2));
		dL=Lab(:,1,1)-Lab(:,1,2);
		dC = C(:,:,1)-C(:,:,2);
		dE = sqrt(sum(diff(Lab,[],3).^2,2));
		dH = sqrt(dE.^2 - dL.^2 - dC.^2);
		sL = 1;
		sC = 1 + 0.045*C(:,:,2);
		sH = 1 + 0.015*C(:,:,2);
		if ~gotstandard
			sC = sqrt(sC.*(1 + 0.045*C(:,:,1)));
			sH = sqrt(sH.*(1 + 0.015*C(:,:,1)));
			end
		z = sqrt((dL./(klch(1)*sL)).^2 + (dC./(klch(2)*sC)).^2 + (dH./(klch(3)*sH)).^2);
		end

	[err,lab1,is1,lab2,is2,mode,klch,gotstandard]=deltainputchk(varargin);
	error(err);
	if strcmp(mode,'single')
		if size(lab1,1)==1
			inshape=is2;
			[err,delta]=optproc([1 0 0 0],[],@i_de94,[lab1 lab2(ones(size(lab1,1),1),:)]);
		elseif size(lab2,1)==1
			inshape=is1;
			[err,delta]=optproc([1 0 0 0],[],@i_de94,lab1(ones(size(lab2,1),1),:),lab2);
		else
			inshape=is1;
			[err,delta]=optproc([1 0 0 0],[],@i_de94,[lab1 lab2]);
			end
	else
		inshape=[is1 is2];
		lab=[
			  reshape(permute(repmat(lab1,[1 1 size(lab2,1)]),[1 3 2]),[],3) ...
			, reshape(permute(repmat(lab2,[1 1 size(lab1,1)]),[3 1 2]),[],3)
			];
		[err,delta]=optproc([1 0 0 0],[],@i_de94,lab);	
		end
	error(err);
	varargout = MultiArgOut(nargout,delta,inshape,1);
	end

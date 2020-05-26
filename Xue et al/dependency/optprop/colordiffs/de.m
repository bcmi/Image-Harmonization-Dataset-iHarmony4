function varargout=de(varargin)
%DE Calculate CIELAB DeltaE.
%   DE calculates the DeltaE values between two set of samples.
%
%   DE(LAB) returns a symmetrical matrix of DE values of all pairs of LAB.
%
%   Z=DE(LAB1,LAB2) or Z=DE(LAB1,LAB2, 'single'), where LAB1 and LAB2 both
%   have size [M N ... T 3] returns Z with size [M N ... T] where each
%   value in LAB1 have been compared to corresponding value in LAB2. LAB1
%   or LAB2 can also have size [1 3] in which case it is expanded to same
%   size as the other.
%
%	Z=DE(LAB1,LAB2,'all'), LAB1 has size [S1 S2 ... SN 3] LAB2 has [T1 T2...TM 3],
%   returns Z with size [S1 S2 ... SN T1 T2...TM];
%
%   Example:
%      Show the error in DE introduced by chromatic adaptation of Lab
%      values compared to proper calculation from spectra
%
%         r=colorchecker;
%         rgb=roo2disp(r);
%         labD65=roo2lab(r,'D65/10');
%         labA=roo2lab(r,'A/10');
%         labD65toA=lab2lab(labD65,'D65/10','A/10');
%         D=de(labA,labD65toA);
%         hb=bar3c(D,rgb);
%         zlabel('D');
%
%   See also DE2000

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: de.m 23 2007-01-28 22:55:34Z jerkerw $
%
% The 'all' option uses the 'distance' routine by Roland Bunschoten:
%    Roland Bunschoten
%    University of Amsterdam
%    Intelligent Autonomous Systems (IAS) group
%    Kruislaan 403  1098 SJ Amsterdam
%    tel.(+31)20-5257524
%    bunschot@wins.uva.nl

	[err,lab1,is1,lab2,is2,type]=deltainputchk(varargin);
	error(err);
	if strcmp(type,'single')
		if size(lab1,1)==1
			inshape=is2;
			[err,delta]=optproc([1 1 0 0],0,@i_deScalar,lab2,lab1);
		elseif size(lab2,1)==1
			inshape=is1;
			[err,delta]=optproc([1 1 0 0],0,@i_deScalar,lab1,lab2);
		else
			inshape=is1;
			[err,delta]=optproc([1 0 0 0],[],@i_deVector,[lab1 lab2]);
			end
		error(err);
	else
		inshape=[is1 is2];
		delta=distance(lab1',lab2');
		end
	varargout=MultiArgOut(nargout,delta,inshape,1);

function delta=i_deScalar(lab,ref)
	delta=sqrt(sum((lab-ref(ones(size(lab,1),1),:)).^2,2));
	
function delta=i_deVector(lablab)
	delta=sqrt(sum((lablab(:,1:3)-lablab(:,4:6)).^2,2));

function d = distance(a,b)
% DISTANCE - computes Euclidean distance matrix
%
% E = distance(A,B)
%
%    A - (DxM) matrix 
%    B - (DxN) matrix
%
% Returns:
%    E - (MxN) Euclidean distances between vectors in A and B
%
%
% Description : 
%    This fully vectorized (VERY FAST!) m-file computes the 
%    Euclidean distance between two vectors by:
%
%                 ||A-B|| = sqrt ( ||A||^2 + ||B||^2 - 2*A.B )
%
% Example : 
%    A = rand(400,100); B = rand(400,200);
%    d = distance(A,B);

% Author   : Roland Bunschoten
%            University of Amsterdam
%            Intelligent Autonomous Systems (IAS) group
%            Kruislaan 403  1098 SJ Amsterdam
%            tel.(+31)20-5257524
%            bunschot@wins.uva.nl
% Last Rev : Oct 29 16:35:48 MET DST 1999
% Tested   : PC Matlab v5.2 and Solaris Matlab v5.3
% Thanx    : Nikos Vlassis

% Copyright notice: You are free to modify, extend and distribute 
%    this code granted that the author of the original code is 
%    mentioned as the original author of the code.

if (nargin ~= 2)
   error('Not enough input arguments');
end

if (size(a,1) ~= size(b,1))
   error('A and B should be of same dimensionality');
end

aa=sum(a.*a,1); bb=sum(b.*b,1); ab=a'*b; 
d = sqrt(abs(repmat(aa',[1 size(bb,2)]) + repmat(bb,[size(aa,2) 1]) - 2*ab));

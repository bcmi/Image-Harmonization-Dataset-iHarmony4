function [err,varargout]=optproc(nd,chk,fun,varargin)
%OPTPROC Block and argument processing for OptProp conversions.
%   OPTPROC acts as a wrapper for all conversion routines, and still some,
%   in the OptProp toolbox. OPTPROC will:
%
%      - collect data input from as many argument as there are colorimetric
%        dimensions in the routine, or just take it from the first
%        argument, whatever complies with the routines calling definition.
%      - reshape multidimensional input into an ordinary 2D array
%      - do formal input checking
%      - replace empty or missing positional arguments with
%        their user defined default values
%      - divide huge input matrices into smaller chunks and repeatedly feed
%        the conversion routines with these chunks until the whole matrix
%        has been processed.
%      - reshape the resulting array back to the input dimensionality,
%        except for the colorimetric input dimensions.
%      - distribute the resulting data onto the output arguments.
%
%   Syntax:
%      [ERR,O1,O2,...OM]=OPTPROC(N,CHK,FUN,I1,I2,...IK)
%
%   Description:
%      FUN is a function handle to a conversion function. The first input
%      argument to FUN is mostly, see below, an ordinary 2D array, with the
%      colorimetric dimensions along the columns. The 1-by-4 argument N
%      holds the specification of the number colorimetric dimensions and
%      the number of arguments to FUN as
%
%      ABS(N(1)) Number of input colorimetric dimensions of FUN
%          N(2)  Number of required positional input arguments
%          N(3)  Number of optional positional input arguments
%          N(4)  Number of optional parameter/value pair arguemnts
%
%      OPTPROC will scan the input arguments for up to ABS(N(1)) equally
%      sized numerical parameters and concatenate them along the next
%      singleton dimension. If this doesn't succeed, the last dimension of
%      the first single input argument is checked whether it is the same as
%      FUNS' input colorimetric dimensions.
%
%      If N(1) is positive, the dimensionality of the resulting, possibly
%      multi-dimensional, matrix is saved and the matrix is reshaped into
%      an ordinary 2D array. This is the setting for conversion routines,
%      where the number of samples output always is the same as samples
%      input.
%
%      If N(1) is negative, the collected N-D matrix is not reshaped, but
%      kept with the same dimensionality. This is for routines that just
%      want to use the input checking and argument distribution. Moreover,
%      no chunking is ever performed, since OPTPROC now can't decide the
%      atomic size of an input sample.
%
%      Because of the previous collection scheme, the subsequent positional
%      arguments,if any, do not have an absolute position. Their position
%      is relative to the the last input argument that went into the
%      collection.
%
%      CHK is a length SUM(N([2 3])) vector holding the type of each posi-
%      tional argument, except for the first, mentioned above. The
%      following types are recognized by OPTPROC:
%
%        Code Description           Example
%         0   Any type              'anything'
%         1   illuminant/observer   'D65/10'
%         2   illuminant            'D65'
%         3   observer              '10'
%         4   RGB type              'srgb'
%         5   wavelength range      400:10:700
%         6   numeric               4711.17
%         7   RGB class             'uint8'
%
%      Each positional input argument is checked according to its type and,
%      except for type 0, empty or missing arguments are replaced with a
%      default value, specified by the user by means of OPTSETPREF.
%
%      Type 5, the wavelength range, is special in that, assuming the
%      routine is a conversion routine, N(1)>0, it also checks that the
%      length of the range is the same as the columns of the collected 2D
%      array.
%
%      If an error occurs, the output argument ERR is filled with an error
%      struct, describing the error. If no error is found, ERR is set to
%      empty. The calling routine can directly raise an error with ERR as
%      input argument. This design was chosen, instead of raising error
%      within OPTPROC, because the error message will focus the attention
%      to the routine called by the user and not on the routine that only
%      discovered the error.
%
%      If FUN is non-conversional, N(1)<0, or the size of data array is less
%      than OPTGETPREF('ChunkSize'), FUN is called as [O1..OM]=FUN(DATA,
%      J1...JK), where DATA is the collected data matrix and J1..JK are
%      positional- and P/V-arguments. Note that all positional arguments of
%      FUN now are filled in.
%
%      If FUN is conversional and the size of data matrix is greater than
%      OPTGETPREF('ChunkSize'), FUN is called the first time as
%      Z=FUN(DATA(1:DR,:), J1...JK), so that DATA(1:DR,:) comprises approx
%      OPTGETPREF('ChunkSize') worth of bytes, and then repeatably calls
%      FUN with new parts of DATA until all of DATA has been converted.
%
%      Still assuming a conversional routine, FUN returns a single 2D array
%      Z with the same number of rows as DATA, but possibly with different
%      number of columns. If, apart from ERR, only a single output argu-
%      ment, O1, is given, the output from FUN is reshaped to the same size
%      as the input, except possibly for the the last dimension. If the
%      number of output arguments, O1..ON, coincides with the number of
%      columns of FUNS' output, each column is reshaped according to the
%      input argument(s) and and assigned to the corresponding output
%      argument, O1..ON.
%
%      If FUN is non-conversional, there is no assumption that the dimen-
%      sionality of the output have anything to do with the input, so the
%      output of FUN is just passed on.
%
%   Example:
%      Create the function XYZ2XY to convert from tristimulus XYZ into
%      chromaticity XY. In the single file xyz2xy.m write:
%
%         [err,varargout{1:max(1,nargout)}]=optproc( ...
%                                     [3 0 0 0],[],@i_xyz2xy,varargin{:});
%         error(err);
% 
%         function xy=i_xyz2xy(XYZ)
%         Denom=sum(XYZ,2);
%         xy=XYZ(:,1:2)./Denom(:,[1 1]);
%
%      XYZ2XY can now be called with various combinations of input an
%      output arguments:
%
%         xy=xyz2xyz(XYZ);
%         xy=xyz2xy(X,Y,Z);
%         [x,y]=xy2xy(XYZ);
%         [x,y]=xyz2xy(X,Y,Z);
%
%      XYZ can have any dimension d1-by-d2-by-...-by-dn-by-3, wich will
%      render xy the dimension d1-by-d2-by-...-by-dn-by-3 and each of x and
%      y the dimension d1-by-d2-by-...-by-dn.

% Part of the OptProp toolbox, $Version: 2.1 $
% Author:  Jerker Wågberg, More Research & DPC, Sweden
% Email: ['jerker.wagberg' char(64) 'more.se']

% $Id: optproc.m 23 2007-01-28 22:55:34Z jerkerw $

	%
	% Set all output parameters, so we don't get that error if we must
	% return prematurely.
	%
	
	outnargs=nargout-1;
	[varargout{1:outnargs}]=deal([]);
	
	check=struct( ...  0         1          2         3         4             5             6            7 
			  'var', {'ANY'     'CWF'      'ILL'     'OBS'     'RGBTYPE'     'WLRANGE'     'NUM'        'RGBCLASS'} ...
			, 'fun',  {@NullCheck @CheckCWF @CheckIll @CheckObs @CheckRGBType @CheckWLRange @CheckNumeric @CheckRGBClass});

	%
	% Formal errors in calling optproc will generate an error, while errors
	% in varargin sets the err struct and returns.
	%
	
	error(nargchk(3,inf,nargin,'struct'));
	if ~isequal(size(nd),[1 4]) && ~isa(nd, 'double')
		error(illpar('Argument description vector must be 1x4 double vector'));
		end
	npp=sum(nd([2 3]));
	if ~isempty(chk) && ~isvector(chk)
		error(illpar('Check vector must be a VECTOR.'));
		end
	if ~isa(nd, 'double') || length(chk)~=npp
		error(illpar('Check vector does not match argument description vector'));
		end
	if any(chk<0 | numel(check)<chk)
		error(illpar(['index in check vector. Valid range is 0:' int2str(numel(check))]));
		end
	if numel(varargin)<1 || ~isnumeric(varargin{1})
		err=usage(illpar('First argument must be numeric.'),callername,check,nd,chk);
		return
		end
	if nd(1)<0
		nfunargs=nargout(fun);
		if nfunargs ~= -1 && nfunargs<outnargs
			err=usage(illpar('Too many output arguments',callername,check,nd,chk,nfunargs));
			return;
			end
		end

	%
	% We lied in the help text. MultiArgIn will indeed reshape the
	% input matrix, but we will re-reshape it if N(1) is negative.
	%

	[err,xyz,InShape,iParms]=MultiArgIn(abs(nd(1)), varargin{:});
	if ~isempty(err); return;end
	if nd(1)<0
		xyz=reshape(xyz, [InShape size(xyz,2)]);
		end
	if ~iscell(iParms); iParms={iParms};end
	nParms=length(iParms);
	Parms=cell(1,sum(nd([2 3])));

	% Make sure we have necessary parameters. Also check that they are
	% valid

	if nd(2)>nParms
		missing=nd(2)-nParms;
		plural={'' 's'};
		err=usage(illpar('Need %d additional parameter%s.', missing,plural{max(1,missing)}),callername,check,nd,chk);
		return
		end

	datacols=size(xyz,2);
	for i=1:nd(2)
		ix=chk(i)+1;
		[err,Parms{i}]=check(ix).fun(iParms{i},i+1,iff(nd(1)<0,0,datacols));
		if ~isempty(err)
			err=usage(err,callername,check,nd,chk);
			return;
			end
		end

	%
	% Now handle the optional positional parameters. For each parameter,
	% check that it is valid. If not, and it's a string, it marks the
	% beginning of P/V-pairs list.
	%

	pvp=0;
	for i=nd(2)+1:npp
		ix=chk(i)+1;
		if pvp==0 && i<=nParms
			[err,Parms{i}]=check(ix).fun(iParms{i},i+1,iff(nd(1)<0,0,datacols));
			if ~isempty(err)
				if ischar(iParms{i}) && nd(4)>0
					% Next line can't raise an error by design.
					[err,Parms{i}]=check(ix).fun([],0,iff(nd(1)<0,0,datacols));
					pvp=i;
				else
					err=usage(err,callername,check,nd,chk);
					return;
					end
				end
		else
			% Next line can't raise an error by design.
			[err,Parms{i}]=check(ix).fun([],0,iff(nd(1)<0,0,datacols));
			end
		end
	if pvp==0
		pvp=min(npp,nParms)+1;
		end
	%
	% Check for excess arguments
	%
	
	if nParms>npp+2*nd(4)
		err=illpar('Too many input arguments');
		return
		end
	%
	% Now check that the PV-pairs are just that.
	%

	if rem(nParms-pvp+1,2)
		err=illpar('Parameter/value pairs must come in PAIRS');
		return
		end
	if ~all(cellfun(@ischar,iParms(pvp:2:end)))
		err=illpar('Parameter/value pairs must have a string as name');
		return
		end
	if (nParms-pvp+1)/2>nd(4)
		err=illpar('Too many parameter/value pairs');
		return
		end
	Parms(npp+(1:nParms-pvp+1))=iParms(pvp:end);

	if nd(1)>0

		%
		% Calculate the maximum number of rows we can send in one chunk. Watch
		% out for empty input.
		%

		v=whos('xyz');
		m=v.size(1);
		if m>0
			cs=round(ChunkSize/(v.bytes/m)); % Max number of rows in a chunk
			if cs==0
				error(illpar('Too much data per sample.\nPreference ''ChunkSize'' must be increased'));
				end
		else
			cs=inf;
			end
		if m>cs
			%
			% Make a test call with empty input
			% to get number of output columns
			%
			newn=size(fun(xyz([],:),Parms{:}),2);
			out=zeros(m,newn);
			hw=waitbar(0,'Calculating optical properties. Please wait...');
			for i=0:floor(m/cs)-1
				waitbar(cs*i/m,hw);
				ix=cs*i+(1:cs);
				out(ix,:)=fun(xyz(ix,:),Parms{:});
				end
			waitbar(cs*(i+1)/m,hw);
			Rest=mod(m,cs);
			if Rest>0
				ix=cs*(i+1)+(1:Rest);
				out(ix,:)=fun(xyz(ix,:),Parms{:});
				end
			delete(hw)
		else
			out=fun(xyz,Parms{:});
			end
		if outnargs>1 && outnargs~=size(out,2)
			err=illpar('%s can only take 1 or %d output arguments.', callername, size(out,2));
			return
			end
		varargout = MultiArgOut(outnargs,out,InShape);
	else
		[varargout{:}]=fun(xyz,Parms{:});
		end

function [err,z]=NullCheck(z,pos,lastdim)
	err=[];

function [err,z]=CheckCWF(x,pos,lastdim)
	err=[];
	if isempty(x)
		z=dcwf;
	else
		if ~iscwf(x)
			err=illpar('Argument %d not a valid illuminant/observer',pos);
			z=[];
		else
			z=x;
			end
		end

function [err,z]=CheckIll(x,pos,lastdim)
	err=[];
	if isempty(x)
		z=cwf2ill(dcwf);
	else
		if ~isilluminant(x)
			err=illpar('Argument %d not a valid illuminant',pos);
			z=[];
		else
			z=x;
			end
		end

function [err,z]=CheckObs(x,pos,lastdim)
	err=[];
	if isempty(x)
		z=cwf2obs(dcwf);
	else
		if ~isobserver(x)
			err=illpar('Argument %d not a valid observer',pos);
			z=[];
		else
			z=x;
			end
		end

function [err,z]=CheckRGBType(x,pos,lastdim)
	err=[];
	if isempty(x)
		z=optgetpref('WorkingRGB');
	elseif isrgbtype(x)
		z=x;
	else
		z=[];
		err=illpar('Argument %d is not a valid RGB type', pos);
		end

function [err,z]=CheckRGBClass(x,pos,lastdim)
	err=[];
	if isempty(x)
		z=optgetpref('DisplayClass');
	elseif isrgbclass(x)
		z=x;
	else
		z=[];
		err=illpar('Argument %d is not a valid RGB class', pos);
		end

function [err,x]=CheckNumeric(x,pos,lastdim)
	if isnumeric(x)
		err=[];
	else
		err=illpar('Argument %d must be numeric', pos);
		end

function [err,z]=CheckWLRange(x,pos,lastdim)
	err=[];
	if isempty(x)
		z=dwl;
	elseif iswlrange(x)
		z=x;
	else
		err=illpar('Argument %d is not a valid wavelength range.', pos);
		z=[];
		return;
		end
	if lastdim>0 && length(z)~=lastdim
		if isempty(x)
			err=illpar('Spectra has different length than default wavelength range',pos);
		else
			err=illpar('Spectra and wavelength range have different lengths',pos);
			end
		return
		end
	z=z(:)';

function z=ChunkSize
	persistent CHUNK_SIZE

	if isempty(CHUNK_SIZE)
		CHUNK_SIZE=optgetpref('ChunkSize');
		end
	z=CHUNK_SIZE;

function z=usage(err,name,check,nd,chk,nout)
	if nargin<6;nout=1;end
	z=err;
	z.message=[z.message char(10) commandline(name,check,nd,chk,nout)];

function z=commandline(name,check,nd,chk,nout)
	%Bukd a command line template
	chk=abs(chk);
	z='Usage: ';

% Haven't decided how to deal with output yet.
% 	n=nd(1);
% 	if n==1
% 		z=[z 'OUT'];
% 	elseif n>1
% 		z=[z '['];
% 		for i=1:n
% 			z=[z 'OUT' int2str(i) ','];		%#ok<AGROW>
% 			end
% 		z(end)=']';
% 		end
% 	z=[z '=' upper(name) '(X'];
 	z=[z upper(name) '(X'];
	needed=[true(1,nd(2)) false(1,nd(3))];
	for i=1:sum(nd([2 3]))
		if ~needed(i); z=[z ' {'];end		%#ok<AGROW>
		z=[z ',' check(chk(i)+1).var];		%#ok<AGROW>
%		if ~needed(i); z=[z '}'];end		%#ok<AGROW>
		end
	z=[z repmat('}',1,nd(3))];
	z=[z ')'];

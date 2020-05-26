function res = existfile(fileName)
%EXISTFILE  Check for file existence.
%	  RES = EXISTFILE(FILENAME) returns true if the file FILENAME is existing
%	  on the current path and false otherwise. It works similar to
%	  EXIST(FILENAME, 'file'), except that it does not find files on the
%	  Matlab path!
%
%		The function is realized as a mex function (existfile.c). To compile
%		the mex-function, move to the directory where file existfile.c is
%		located and type
%		
%		  mex existfile.c
%
%		If this is the first time you run function MEX on your system, you
%		might have to select a compiler by typing
%
%		  mex -setup
%
%		If the mex-file (e.g. existfile.mexw32 or existfile.mexglx) is not
%		existing, a (very slow) MATLAB realization is called instead.
%
%		Example:
%		existfile('test.txt');
%
%		Markus Buehren
%		Last modified 03.02.2008 
% 
%   See also EXIST.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% persistent warnmex
% if isempty(warnmex)
% 	fprintf('This is the m-file %s.m, not the mex-file! Type "mex existfile.c" to compile.\n', mfilename);
% 	warnmex = 1;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check input arguments
res = exist(fileName, 'file') ~= 0;

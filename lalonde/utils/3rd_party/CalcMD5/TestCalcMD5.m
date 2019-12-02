function TestCalcMD5(doSpeed)
% Automatic test: CalcMD5 (Mex)
% This is a routine for automatic testing. It is not needed for processing and
% can be deleted or moved to a folder, where it does not bother.
%
% TestCalcMD5(doSpeed)
% INPUT:
%   doSpeed: Optional logical flag to trigger time consuming speed tests.
%            Default: TRUE. If no speed test is defined, this is ignored.
% OUTPUT:
%   On failure the test stops with an error.
%   The speed is compared to a Java method.
%
% Tested: Matlab 6.5, 7.7, 7.8, WinXP
% Author: Jan Simon, Heidelberg, (C) 2009-2010 J@n-Simon.De

% $JRev: R5.00g V:013 Sum:uNknB6D/Ksze Date:12-Dec-2009 00:14:15 $
% $File: CalcMD5\TestCalcMD5.m $

% Initialize: ==================================================================
% Global Interface: ------------------------------------------------------------
FuncName = 'TestCalcMD5';  % $Managed by AutoFuncPath$

% Initial values: --------------------------------------------------------------
if nargin == 0
   doSpeed = true;
end

% Program Interface: -----------------------------------------------------------
% User Interface: --------------------------------------------------------------
% Do the work: =================================================================
disp(['==== Test CalcMD5,  ', datestr(now, 0)]);

TestData = {'', 'd41d8cd98f00b204e9800998ecf8427e'; ...
      'a', '0cc175b9c0f1b6a831c399e269772661'; ...
      'abc', '900150983cd24fb0d6963f7d28e17f72'; ...
      'message digest', 'f96b697d7cb7938d525a2f31aaf161d0'; ...
      'abcdefghijklmnopqrstuvwxyz', 'c3fcd3d76192e4007dfb496cca67e13b'; ...
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789', ...
      'd174ab98d277d9f5a5611c2c9f419d9f'; ...
      ['123456789012345678901234567890123456789012345678901234567890123456', ...
         '78901234567890'], '57edf4a22be3c955ac49da2e2107b67a'; ...
      char(0:255), 'e2c865db4162bed963bfaa9ef6ac18f0'};  % Not in RFC1321

fprintf('  Known answer test from RFC 1321 for strings and files:');
TestFile = tempname;

% Loop over test data:
for iTest = 1:size(TestData, 1)
   % Check string input:
   Str = CalcMD5(TestData{iTest, 1}, 'char');
   if strcmpi(Str, TestData{iTest, 2}) == 0
      fprintf('\n');
      error(['*** ', FuncName, ': Failed for string:', ...
            char(10), '[', TestData{iTest, 1}, ']']);
   end
   
   % Check file input:
   FID = fopen(TestFile, 'wb+');
   if FID < 0
      fprintf('\n');
      error(['*** ', FuncName, ': Cannot open test file [', TestFile, ']']);
   end
   fwrite(FID, TestData{iTest, 1}, 'uchar');
   fclose(FID);
   
   Str2 = CalcMD5(TestFile, 'file');
   if strcmpi(Str2, TestData{iTest, 2}) == 0
      fprintf('\n');
      error(['*** ', FuncName, ': Failed for file:', ...
            char(10), '[', TestData{iTest, 1}, ']']);
   end
end
fprintf(' ok\n');
delete(TestFile);

% Check different output types:
N = 1000;
fprintf('  %d random tests with hex, HEX, dec and base64 output: ', N);
for i = 1:N
   data      = uint8(fix(rand(1, 1 + fix(rand * 100)) * 256));
   lowHexOut = CalcMD5(data, 'char', 'hex');
   upHexOut  = CalcMD5(data, 'char', 'HEX');
   decOut    = CalcMD5(data, 'char', 'Dec');
   b64Out    = CalcMD5(data, 'char', 'Base64');
   
   if not(strcmpi(lowHexOut, upHexOut) && ...
         isequal(sscanf(lowHexOut, '%2x'), decOut(:)) && ...
         isequal(Base64decode(b64Out), decOut))
      fprintf('\n');
      error(['*** ', FuncName, ': Different results for output types.']);
   end
   
   % Check unicode, if the data length is a multiple of 2:
   if rem(length(data), 2) == 0
      doubleData = double(data);
      uniData    = char(doubleData(1:2:end) + 256 * doubleData(2:2:end));
      uniOut     = CalcMD5(uniData, 'unicode', 'dec');
      if not(isequal(uniOut, decOut))
         fprintf('\n');
         error(['*** ', FuncName, ': Different results for unicode input.']);
      end
   end
end
fprintf('ok\n');
fprintf('  Unicode input: ok\n\n');

% Speed test: ------------------------------------------------------------------
if doSpeed
   disp('== Test speed:');
   disp('(Short data: mainly the overhead of calling the function)');
   Delay = 2;
   
   for Len = [10, 100, 1000, 10000, 1e5, 1e6, 1e7]
      [Number, Unit] = UnitPrint(Len);
      fprintf('  Data length: %s %s:\n', Number, Unit);
      data = uint8(fix(rand(1, Len) * 256));
      
      % Measure java time:
      iniTime  = cputime;
      finTime  = iniTime + Delay;
      javaLoop = 0;
      while cputime < finTime
         x        = java.security.MessageDigest.getInstance('MD5');
         x.update(data);
         javaHash = double(typecast(x.digest, 'uint8'));
         javaLoop = javaLoop + 1;
      end
      javaLoopPerSec = javaLoop / (cputime - iniTime);
      [Number, Unit] = UnitPrint(javaLoopPerSec * Len);
      fprintf('    java: %6s %s/sec\n', Number, Unit);
      
      % Measure Mex time:
      iniTime = cputime;
      finTime = iniTime + Delay;
      mexLoop = 0;
      while cputime < finTime
         mexHash = CalcMD5(data, 'char', 'dec');
         mexLoop = mexLoop + 1;
      end
      mexLoopPerSec = mexLoop / (cputime - iniTime);
      [Number, Unit] = UnitPrint(mexLoopPerSec * Len);
      fprintf('    mex:  %6s %s/sec: %.1f times faster\n', ...
         Number, Unit, mexLoopPerSec / javaLoopPerSec);
      
      % Compare the results:
      if ~isequal(javaHash(:), mexHash(:))
         error(['*** ', FuncName, ': Different results from java and Mex.']);
      end
   end
end

fprintf('\nCalcMD5 seems to work well.\n');
   
return;

% ******************************************************************************
function Out = Base64decode(In)
% Decode from base 64

% Initialize: ==================================================================
Pool = [65:90, 97:122, 48:57, 43, 47];  % [0:9, a:z, A:Z, +, /]
v8   = [128, 64, 32, 16, 8, 4, 2, 1];
v6   = [32; 16; 8; 4; 2; 1];

% Do the work: =================================================================
In          = reshape(In, 1, []);
Table       = zeros(1, 256);
Table(Pool) = 1:64;
Value       = Table(In) - 1;

X   = rem(floor(Value(ones(6, 1), :) ./ v6(:, ones(length(In), 1))), 2);
Out = v8 * reshape(X(1:fix(numel(X) / 8) * 8), 8, []);

return;

% ******************************************************************************
function [Number, Unit] = UnitPrint(N)

if N < 1000
   Number = sprintf('%d', round(N));
   Unit   = 'Byte';
elseif N < 1e6
   Number = sprintf('%.1f', N / 1000);
   Unit   = 'kB';
else
   Number = sprintf('%.1f', N / 1e6);
   Unit   = 'MB';
end

return;

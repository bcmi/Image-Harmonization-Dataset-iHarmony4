function x = testfun(timeInSeconds, x)
%TESTFUN  Do something stupid that takes some time to compute.
%   Y = TESTFUN(TIME, X) does some computations that take TIME seconds long
%   and returns the input value X.
%
%		Markus Buehren
%		Last modified 07.01.2009

% do something stupid that takes timeInSeconds seconds
t0 = mbtime;
epsTime = 0.005;
while mbtime - t0 < timeInSeconds - epsTime
	for k = 1:20
		a = svd(rand(20)); %#ok
  end
end
%disp(sprintf('testfun took %.4f seconds.', mbtime - t0));


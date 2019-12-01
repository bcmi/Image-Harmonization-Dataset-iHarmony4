function postprocessdemo(postProcStruct)
%POSTPROCESSDEMO  Example for a user-defined postprocessing function.
%   POSTPROCESSDEMO(POSTPROCSTRUCT) accepts a structure passed by function
%   STARTMULTICOREMASTER and makes some command-line outputs. The functions
%   shall demonstrate the basic use of the postprocessing function.
%
%   Markus Buehren
%   Last modified 19.06.2009
%
%   See also STARTMULTICOREMASTER.

persistent lastDisplayTime
if isempty(lastDisplayTime)
  lastDisplayTime = mbtime;
end

if strcmp(postProcStruct.state, 'initialization')
  disp(sprintf('Multicore demo started at %s', postProcStruct.userData));
end  

if mbtime - lastDisplayTime > 2.0
  lastDisplayTime = mbtime;

  disp(sprintf('Current time: %s.', datestr(now)));
  disp(sprintf('Jobs done by master: %2d',     postProcStruct.nrOfFilesMaster));
  disp(sprintf('Jobs done by slave:  %2d',     postProcStruct.nrOfFilesSlaves));

end
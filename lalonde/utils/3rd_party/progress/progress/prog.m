function prog(script_name)
  %PROG Runs a script with progress bars
  %If a script has been correctly annotated and calls 'prog' initially,
  %then prog will automatically generate a temporary file with boilerplate
  %code for progress bars, run this code in the base workspace, and delete
  %the temporary file. The initial annotation should look like:
  %
  %prog;return;
  %
  %and then the script should be executed as normal.
  %
  %Alternatively, the script can be annotated with %%p# tags and then
  %invoked via "prog('scriptname')" where scriptname is the name of the
  %script without a trailing ".m"; for example, my_script.m should be
  %invoked with
  %
  %prog('my_script');
  %
  %In general, prefer the first method.
  %
  %For detail on how to annotate code, see the Progress help.
  %
  %See also: PROGRESS, PROGRESS_EXAMPLE
  
  %Author: Richard Stapenhurst
  %$Date: 6/07/2010$
  
  if (nargin == 0)
    %Find the name (sans .m) of the caller script
    script_name = feval(@(y)y.name, feval(@(x)x(2), dbstack));
  end
  %Compute the temporary file name
  new_file = [script_name '_pr.m'];
  %Schedule a cleanup task in case of ctrl-c or some other exception
  onCleanup(@()completion(script_name));
  %Remove the file if it already exists
  if (exist(new_file, 'file'))
    delete(new_file);
    %Hack to make evalin recognise the new file
    null = which(new_file); %#ok<NASGU>
  end
  %Create temp file with boilerplate code
  Progress.annotate([script_name '.m']);
  %Hack to make evalin recognise the new file
  null = which(new_file); %#ok<NASGU>
  %Run the annotated file
  evalin('base', new_file(1:end-2));

end

function completion(script_name)
  %COMPLETETION Delete any temporary scripts that we made.
  delete([script_name '_pr.m']);
  if exist([script_name '_fn.m'], 'file')
    delete([script_name '_fn.m']);  
  end
  Progress.tidy();
end
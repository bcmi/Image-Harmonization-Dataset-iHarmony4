function deleteSuccessful = mbdelete(fileName, showWarnings, throwError)
%MBDELETE  Delete file and check possible warnings.
%   RESULT = MBDELETE(FILE) will check if file FILE is existing, try to
%   delete the file and check if the deletion caused a warning afterwards.
%   If the file could be deleted or was not existing, TRUE is returned,
%   otherwise FALSE.
%
%   RESULT = MBDELETE(FILE, SHOWWARNING, THROWERROR) with THROWERROR
%   evaluating to TRUE will cause MBDELETE to throw an error if Matlab
%   would have given a warning. With SHOWWARNING evaluating to false,
%   MBDELETE will not display a warning. Default values are THROWERROR =
%   FALSE and SHOWWARNING = TRUE.
%
%   Markus Buehren
%   Last modified 07.04.2009
%
%   See also DELETE, EXISTFILE, WARNING, LASTWARN.

showErrors = 0;

if existfile(fileName)
  % turn off file permission warnings
  warnID = 'MATLAB:DELETE:Permission';
  warnState = warning('query', warnID);
  warning('off', warnID);

  % reset warnings and errors
  lastwarn('');
	lasterror('reset');

  % try to delete file
  try    
    delete(fileName); %% file access %%
    
    % check last warning
    [lastMsg, lastWarnID] = lastwarn;
    deleteSuccessful = ~strcmp(lastWarnID, warnID);
  
  catch
    % deleting caused an error
    deleteSuccessful = false;
    
    if showErrors
      disp(textwrap2(sprintf('Error thrown when trying to remove file %s:', fileName)));
      displayerrorstruct;
    end
  end
        
  % warn or throw error if deletion was not successful
  if ~deleteSuccessful
    
    if ~exist('throwError', 'var')
      throwError = 0;
    end
    if ~exist('showWarnings', 'var')
      showWarnings = 1;
    end
 
    if throwError
      error(textwrap2(sprintf('Error: Unable to remove file %s.', fileName)));
      
    elseif showWarnings
      disp(textwrap2(sprintf('Warning: Unable to remove file %s.', fileName)));
      
      % display warning (if any)
      if ~isempty(lastMsg)
        disp(textwrap2(sprintf('Warning issued when trying to remove file %s:\n%s', ...
          fileName, lastMsg)));
      end
    end
  end

  % reset warning state
  warning(warnState);
else
  deleteSuccessful = true;
end




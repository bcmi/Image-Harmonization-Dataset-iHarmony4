function hostName = gethostname
%GETHOSTNAME  Get host name.
%		HOSTNAME = GETHOSTNAME returns the name of the computer that MATLAB 
%		is running on. Function should work for both Linux and Windows.
%
%		Markus Buehren
%		Last modified: 20.08.2009
%
%		See also GETUSERNAME.

persistent hostNamePersistent

if isempty(hostNamePersistent)

    % the environment variable above was not existing
    if ispc
        systemCall = 'hostname';
    else
        systemCall = 'uname -n';
    end
    if ispc
        % The current directory may be a network-directory. This is not
        % supported by Windows' cmd.exe, which results in a wrong host
        % name. Therefore we return to a default-directory first.
        currDir = cd;
        cd('C:\');
    end
    [status, hostName] = system(systemCall);
    if ispc
        cd(currDir);
    end
    if status ~= 0
        error('System call "%s" failed with return code %d.', systemCall, status);
    end
    hostName = hostName(1:end-1);
    
    % environment variable and system call might result different, so only
    % allow upper case letters
    hostName = upper(hostName);
    
    % save string for next function call
    hostNamePersistent = hostName;
else
	% return string computed before
	hostName = hostNamePersistent;
end

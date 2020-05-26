function tempDir2 = tempdir2
%TEMPDIR2  Return temporary directory.
%		DIR = TEMPDIR2 returns as a temporary directory the directory
%		<TEMPDIR>/<USERNAME>@<HOSTNAME>/MATLAB. This directory is user- and
%		host-specific and thus better suited in networks/clusters than the
%		temporary directory returned by Matlab function TEMPDIR.
%
%		Markus Buehren
%		Last modified 20.04.2008
%
%		See also TEMPDIR, GETUSERNAME, GETHOSTNAME.

persistent tempDir2Persistent

if isempty(tempDir2Persistent)

  % build directory string
  tempDir2 = tempdir;
  tempDir2 = fullfile(tempDir2, [getusername '@' gethostname], 'MATLAB');

  % if directory is not existing, try to create it
  if ~exist(tempDir2, 'dir')
    try
      mkdir(tempDir2);
    catch
      error('Unable to create directory %s.', tempDir2);
    end
  end

  % save string for next function call
  tempDir2Persistent = tempDir2;
else
  % return string computed before
  tempDir2 = tempDir2Persistent;
end


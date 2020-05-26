function fileDateVector = getfiledate(fileNameIn)
%GETFILEDATE  Get file modification date as serial date number.
%   FILEDATE = GETFILEDATE(FILENAME) returns the modification date of the
%   given file as a serial number.
%
%   FILEDATES = GETFILEDATE(FILENAMECELL) works on the cell FILENAMECELL of
%   file names and returns a vector of file dates.
%
%   Markus Buehren
%   Last modified 09.10.2008
%
%   See also DIR, DATENUM2, GETFILESIZE.

if ischar(fileNameIn)
  fileNameCell = {fileNameIn};
else
  fileNameCell = fileNameIn;
end

fileDateVector = zeros(size(fileNameCell));
for fileNr=1:length(fileNameCell)
  dirStruct = dir(fileNameCell{fileNr});
  if ~isempty(dirStruct)
    if isfield(dirStruct, 'datenum')
      fileDateVector(fileNr) = dirStruct.datenum;
    else
      fileDateVector(fileNr) = datenum2(dirStruct.date);
    end
  else
    fileDateVector(fileNr) = NaN;
  end
end

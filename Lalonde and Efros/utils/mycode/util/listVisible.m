function dirList = listVisible(inputDir)

dirList = getFilesFromDirectory(inputDir);
% dirList = dir(inputDir);
% dirList = {dirList.name};
% validDir = cellfun(@(x) ~isequal(x(1), '.'), dirList);
% dirList = dirList(validDir);
% dirList = sort(dirList); % always in alphabetical order
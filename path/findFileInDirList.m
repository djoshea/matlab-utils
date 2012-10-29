function file = findFileInDirList(fileName, dirList)
% file = findFileInDirList(fileName, dirList)
% returns the first file that exists by concatenating dirList{i}/fileName

assert(iscellstr(dirList), 'fileList must be a cell array of strings');

for i = 1:length(fileList)
    file = fullfile(dirList{i}, fileName);
    if exist(file, 'file') 
        return;
    end
end

file = '';


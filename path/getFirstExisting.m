function file = getFirstExisting(fileList)
% file = getFirstExisting(fileList)
% returns the first file that exists (dir or file) in fileList

assert(iscellstr(fileList), 'fileList must be a cell array of strings');

for i = 1:length(fileList)
    file = fileList{i};
    if exist(file, 'file') || exist(file, 'dir')
        return;
    end
end

file = '';


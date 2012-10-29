function mkdirRecursive(dirPath)
% like mkdir -p : creates intermediate directories as required

if exist(dirPath, 'dir')
    return;
else
    parent = fileparts(dirPath);
    if ~isempty(parent)
        mkdirRecursive(parent);
    end
    mkdir(dirPath);
end

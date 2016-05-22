function mkdirRecursive(dirPath, cdTo)
% like mkdir -p : creates intermediate directories as required

if exist(dirPath, 'dir')
    if nargin >= 2 && cdTo
        cd(dirPath);
    end
    return;
else
    parent = fileparts(dirPath);
    if ~isempty(parent)
        mkdirRecursive(parent);
    end

    s = warning('off', 'MATLAB:MKDIR:DirectoryExists');
    mkdir(dirPath);
    warning(s);
end

if nargin < 2
    cdTo = false;
end
if cdTo
    cd(dirPath);
end

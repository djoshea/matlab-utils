function addPathRecursive(folder)
% addPathRecursive(folder)
% Adds a folder and all non-hidden subdirectories to the path

    pathstr = genpath(folder);
    
    % remove hidden folders beginning with .
    folders = strsplit(pathstr, ':');
    hiddenDirMask = cellfun(@(x) ~isempty(x), regexp(folders, '/\.[^/]+/*', 'start'));
    folders = folders(~hiddenDirMask);
    pathstr = strjoin(folders, ':');

    addpath(pathstr);

end

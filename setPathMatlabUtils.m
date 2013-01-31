function setPathMatlabUtils()
    % get folder that I am located in
    codeRoot = fileparts(mfilename('fullpath'));  

    fprintf('Path: Adding matlab-utils at %s\n', codeRoot);
    
    % addPathRecursive depends on string functions
    addpath(fullfile(codeRoot, 'string'));
    
    thisPath = fileparts(mfilename('fullpath'));
    % add this manually as addPathRecursive is located there
    addpath(fullfile(codeRoot, 'path'));
    addPathRecursive(codeRoot);
end

function [parent, leaf, ext] = filepartsMultiExt(file)
    % like fileparts, but a multiple extension file like file.test.meta
    % will end up with leaf = file and ext = .test.meta
    
    [parent, leaf, ext] = fileparts(file);
    if ~isempty(ext)
        [leaf, ext] = strtok([leaf, ext], '.');
    end
end
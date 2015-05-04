function d = pathToThisFile()
% Returns the path to the folder in which the currently executing file is located
    stack = dbstack('-completenames');
    
    if numel(stack) <= 2
        % assume executing in cell mode
        d = matlab.desktop.editor.getActiveFilename();
    else
        d = fileparts(stack(2).file);
    end
end


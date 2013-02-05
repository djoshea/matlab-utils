function className = classNameCurrentMethod()
% Returns the path to the folder in which the currently executing file is located
    stack = dbstack('-completenames');
    [d, className] = fileparts(stack(2).file);
end


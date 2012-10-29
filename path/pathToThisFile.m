function d = pathToThisFile();
% Returns the path to the folder in which the currently executing file is located
    file = evalin('caller', 'mfilename(''fullpath'')');
    d = fileparts(file);
end


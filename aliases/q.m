try
    dbclear if error
    evalin('caller', 'dbquit all');
    evalin('base', 'dbquit all');
    dbquit all
catch e
    disp('Couldn''t debug quit');
end

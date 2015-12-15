try
    dbclear if error
    dbquit all
    evalin('base', 'dbquit all');
catch e
    disp('Couldn''t debug quit');
end

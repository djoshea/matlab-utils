try
    evalin('base', 'dbclear if error');
    evalin('base', 'dbquit(''all'')');
catch
end

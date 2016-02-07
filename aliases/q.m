try
    evalin('caller', 'dbquit all');
%     evalin('base', 'dbquit all');
catch e
    disp('Couldn''t debug quit');
    disp(e)
end

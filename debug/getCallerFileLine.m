function caller = getCallerFileLine()

    [st, i] = dbstack();
    if length(st) == 1
        caller.origin = 'Base';
        caller.line = 0;
        caller.method = 'interactive';
    else
        caller.origin = strtok(st(2).file, '.');
        caller.line = st(2).line;
        [~, method] = strtok(st(2).name, '.');
        method = method(2:end);
        caller.method = method;
    end
end
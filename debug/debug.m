function debug(varargin)
    % acts like fprintf in terms of arguments
    % prints a colored message which describes the class and function name of the caller
    % and the line number from which the call originated. Tracks the last calling function
    % in order to avoid printing redundant messages
    %
    % Include a trailing newline in your format string just like with fprintf
    %
    % Example: debug('Loading %s\n', fileName);
    %
    persistent pLastCaller;

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

    if isempty(pLastCaller) || ~strcmp(pLastCaller.origin, caller.origin) || ...
        ~strcmp(pLastCaller.method, caller.method)
        % new caller file or method, print header line
        tcprintf('yellow', '%s', caller.origin); 
        if ~isempty(caller.method)
            tcprintf('green', '.%s ', caller.method);
        end
        tcprintf('darkGray', ' ::\n');
        pLastCaller = caller;
    end

    if caller.line == 0
        fprintf('     ');
    else
        tcprintf('blue', '%4d ', caller.line);
    end
    if ~isempty(varargin)
        tcprintf('gray', varargin{:});
    else
        tcprintf('gray', '\n');
    end

end

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

    [st, i] = dbstack('-completenames');
    if length(st) == 1
        caller.origin = 'Base';
        caller.line = 0;
        caller.method = 'interactive';
        caller.package = '';
    else
        % determine package name 
        caller.package = getPackage('stackOffset', 1);
        
        [~, fileName] = fileparts(st(2).file);
        caller.origin = fileName;
        
        caller.line = st(2).line;
        [~, method] = strtok(st(2).name, '.');
        method = method(2:end);
        caller.method = method;
    end

    if isempty(pLastCaller) || ~strcmp(pLastCaller.origin, caller.origin) || ...
        ~strcmp(pLastCaller.method, caller.method) || ...
        ~strcmp(pLastCaller.package, caller.package)
    
        if ~isempty(caller.package)
            tcprintf('purple', '%s.', caller.package);
        end
        
        % new caller file or method, print header line
        if ~isempty(caller.method)
            % is a class method
            tcprintf('bright red', '%s', caller.origin);
            tcprintf('bright green', '.%s', caller.method);
        else
            % not class method
            tcprintf('bright green', '%s', caller.origin); 
        end
        tcprintf('darkGray', ' ::\n');
        pLastCaller = caller;
    end

    if caller.line == 0
        fprintf('     ');
    else
        tcprintf('cyan', '%4d ', caller.line);
    end
    if ~isempty(varargin)
        tcprintf('gray', varargin{:});
    else
        tcprintf('gray', '\n');
    end

end

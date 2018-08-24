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
    
    if nargin == 0
        % if nothing provied, simply clear the last caller information so
        % that new calls start with a fresh header
        pLastCaller = [];
        return;
    end

    [st, ~] = dbstack('-completenames');
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
            hcprintf('{c79fef}%s.', caller.package);
        end
        
        % new caller file or method, print header line
        if ~isempty(caller.method)
            % is a class method
            hcprintf('{0485d1}%s', caller.origin);
            hcprintf('{9ffeb0}.%s', caller.method);
        else
            % not class method
            hcprintf('{9ffeb0}%s', caller.origin); 
        end
        hcprintf('{607c8e} ::\n');
        pLastCaller = caller;
    end

    if caller.line == 0
        fprintf('     ');
    else
        hcprintf('{5a7d9a}%4d ', caller.line);
    end
    hcprintf(varargin{:});
    
    setItermStatus(sprintf(varargin{:}));
end

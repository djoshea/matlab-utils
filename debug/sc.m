function sc(varargin)

    p = inputParser();
    p.addParameter('file', '', @ischar);
    p.addParameter('line', [], @(x) isscalar(x) || isempty(x));
    p.parse(varargin{:});


    if isempty(p.Results.file)
        file = matlab.desktop.editor.getActiveFilename();
    else
        file = p.Results.file;
    end
    if isempty(p.Results.line)
        doc = matlab.desktop.editor.openDocument(file);
        line = doc.Selection(1);
    else
        line = p.Results.line;
    end

%     debug('Setting current cell to %s:%d\n', file, line);
    rc('file', file, 'line', line, 'run', false);
end


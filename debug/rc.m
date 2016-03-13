function rc(varargin)
    p = inputParser();
    p.addParameter('file', '', @ischar);
    p.addParameter('line', [], @(x) isscalar(x) || isempty(x));
    p.addParameter('run', true, @islogical);
    p.parse(varargin{:});

    persistent pFile;
    persistent pLine;

    if ~isempty(p.Results.file)
        pFile = matlab.desktop.editor.getActiveFilename();
    end
    if ~isempty(p.Results.line)
        matlab.desktop.editor.openDocument(pFile);
        pLine = p.Results.line;
    end

    if isempty(pFile)
        pFile = matlab.desktop.editor.getActiveFilename();
        if isempty(pFile)
            return;
        end
    end
    if isempty(pLine)
        doc = matlab.desktop.editor.openDocument(pFile);
        pLine = doc.Selection(1);
    end
    
%     debug('Opening cell at %s:%d\n', pFile, pLine);
    matlab.desktop.editor.openAndGoToLine(pFile, pLine);
    drawnow;
    pause(0.01);
    
    % get the handle for the "run section" button
    desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
    jEditor = desktop.getGroupContainer('Editor').getTopLevelAncestor;

   if p.Results.run
        btnRunCell = findjobj(jEditor, 'nomenu', 'class', 'com.mathworks.toolstrip.components.TSButton', ...
        '-property', {'ActionCommand', 'eval-cell'});
        btnRunCell.Enabled = true;
        javaMethodEDT('doClick', btnRunCell);
    end

end


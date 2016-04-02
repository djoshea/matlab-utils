function resizeFig(figName, wStr, hStr, varargin)
    p = inputParser();
    p.addParameter('as', '', @ischar);
    p.addParameter('removeTitles', false, @islogical);
    p.addParameter('restoreDefaultFonts', true, @islogical);
    p.parse(varargin{:});
    
    [loc, name, ext] = fileparts(figName);
    
    roundTo = @(v, d) round(v*10^d) / 10^d;
    
    assert(strcmpi(ext, '.fig'), 'Must be .fig file');
    figh = open(figName);
    
    set(figh, 'WindowStyle', 'normal');
    
    if p.Results.restoreDefaultFonts
        figSetFontsToDefault(figh);
    end
    
    if p.Results.removeTitles
        axh = findobj(figh, 'Type', 'axes');
        for i = 1:numel(axh)
            title(axh, '');
        end
    end
    
    set(figh, 'PaperUnits' ,'centimeters');
    set(figh, 'Units', 'centimeters');
    drawnow;
    figPos = get(figh,'Position');
    aspect = figPos(3) / figPos(4);

    if isempty(hStr)
        wNew = convertToCm(wStr);
        hNew = wNew / aspect;
    else
        hNew = convertToCm(hStr);
        if isempty(wStr)
            wNew = hNew * aspect;
        else
            wNew = convertToCm(wStr);
        end
    end

     if isempty(p.Results.as)
        if isempty(hStr)
            % generate name__w#.pdf'
            newName = sprintf('%s_w%.f.pdf', name, roundTo(wStr, 3));
        elseif isempty(wStr)
            % generate name__h#.pdf'
            newName = sprintf('%s_h%.f.pdf', name, roundTo(hStr, 3));
        else
            % generate name__h#.w#.pdf
            newName = sprintf('%s_w%.f_h%.f.pdf', name, roundTo(wStr, 3), roundTo(hStr, 3));
        end
        newLoc = loc;
     else
        [newLoc, newName, newExt] = fileparts(p.Results.as);
        if isempty(newLoc)
            newLoc = loc;
        end
        newName = [newName newExt];
     end
   
    
    fprintf('Resizing %s to %s\n', fullfile(loc, [name ext]), fullfile(newLoc, newName));
   
    set(figh, 'PaperPositionMode', 'auto');
    newPos = [figPos(1), figPos(2), wNew, hNew];
    set(figh, 'Position', newPos);

    AutoAxis.updateFigure();
    drawnow;
    
    s = fullfile(newLoc, newName);
    
    saveFigureAuto(s, gcf);
end

function cm = convertToCm(num)
    if ischar(num)
        match = regexp(num, '(?<value>\d+)(?<units>[a-zA-Z]+)', 'names');

        match.value = str2double(match.value);

        if isempty(match)
            error('Could not parse length %s', num);
        end

        switch match.units
            case 'cm'
                cm = match.value;
            case 'in'
                cm = match.value * 2.54;
            case 'pt',
                cm = match.value / 72 * 2.54;
            otherwise
                error('Unknown units %s', match.units);
        end
    else
        cm = num;
    end
end

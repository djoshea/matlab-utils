function generateSizedPdfForLatex(figName, h, w)
    set(0, 'DefaultFigureWindowStyle', 'normal');
    
    [loc, name, ext] = fileparts(figName);
    assert(strcmpi(ext, '.fig'), 'Must be .fig file');
    figh = open(figName);
    
    set(figh, 'PaperUnits' ,'centimeters');
    set(figh, 'Units', 'centimeters');
    figPos = get(figh,'Position');

    set(figh, 'PaperPositionMode', 'auto');
    newPos = [figPos(1), figPos(2), w, h];
    set(figh, 'Position', newPos);

    roundTo = @(v, d) round(v*10^d) / 10^d;
    
    s = fullfile(loc, sprintf('%s_%gx%g.pdf', name, roundTo(h, 3), roundTo(w, 3)));
    saveFigure(s, gcf);
end
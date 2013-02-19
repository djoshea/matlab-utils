function figSetFonts(varargin)
    p = inputParser;
    p.addOptional('hfig', gcf, @ishandle);
    p.KeepUnmatched = true;
    p.parse(varargin{:});
    hfig = p.Results.hfig;
    
    hfont = findobj(hfig, '-property', 'FontName');
    set(hfont, p.Unmatched);
end

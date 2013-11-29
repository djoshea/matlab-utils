function figSetFonts(varargin)
    p = inputParser;
    p.addOptional('hfig', gcf, @ishandle);
    p.KeepUnmatched = true;
    p.parse(varargin{:});
    hfig = p.Results.hfig;
    
    hfont = findobj(hfig, '-property', 'FontName');
    set(hfont, p.Unmatched);
    
    % handle all the rest (Title, 
    htext = findall(hfig, 'Type', 'Text');
    set(htext, p.Unmatched);
end

function figSetFonts(varargin)
    p = inputParser;
    p.addOptional('hfig', gcf, @ishandle);
    p.KeepUnmatched = true;
    p.parse(varargin{:});
    hfig = p.Results.hfig;

    set(findall(hfig, 'type', 'text'), p.Unmatched);
end

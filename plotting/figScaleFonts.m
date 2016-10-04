function figScaleFonts(by, varargin)
% figSetFonts(hfig, 'Property', val, ...) or figSetFonts('Property', val, ...)
%
% Applies a set of properties to all text objects in figure hfig (defaults
% to gcf if ommitted).
% 
% Example: figSetFonts('FontSize', 18);

    p = inputParser;
    p.addOptional('hfig', gcf, @ishandle);
    p.parse(varargin{:});
    hfig = p.Results.hfig;
    
    hfont = findall(hfig, '-property', 'FontSize');
    for i = 1:numel(hfont)
        hfont(i).FontSize = hfont(i).FontSize * by;
    end
end


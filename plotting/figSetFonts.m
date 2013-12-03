function figSetFonts(varargin)
% figSetFonts(hfig, 'Property', val, ...) or figSetFonts('Property', val, ...)
%
% Applies a set of properties to all text objects in figure hfig (defaults
% to gcf if ommitted).
% 
% Example: figSetFonts('FontSize', 18);

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

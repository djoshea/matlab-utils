function h = vertLine(xVal, varargin)

h = nan(numel(xVal), 1);
for i = 1:numel(xVal)
    h = plot([xVal(i), xVal(i)], [-flintmax, flintmax], ...
        'Color', [0.5 0.5 0.5], varargin{:}, 'YLimInclude', 'off');
end
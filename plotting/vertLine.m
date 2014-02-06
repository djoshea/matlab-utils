function h = vertLine(xVal, varargin)

big = 1e10;

h = nan(numel(xVal), 1);
for i = 1:numel(xVal)
    h = plot([xVal(i), xVal(i)], [-big, big], ...
        'Color', [0.5 0.5 0.5], varargin{:}, 'YLimInclude', 'off');
end
function h = horzLine(yVal, varargin)

big = 1e10;

h = nan(numel(yVal), 1);
for i = 1:numel(yVal)
    h(i) = plot([-big, big], [yVal(i), yVal(i)], ...
        'Color', [0.5 0.5 0.5], varargin{:}, 'XLimInclude', 'off');
    set(get(get(h(i), 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
end
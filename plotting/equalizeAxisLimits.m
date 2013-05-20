function equalizeAxisLimits(hax)

yl = cell2mat(get(hax, 'YLim'));
yl = [min(yl(:, 1)) max(yl(:, 2))];
xl = cell2mat(get(hax, 'XLim'));
xl = [min(xl(:, 1)) max(xl(:, 2))];

set(hax, 'YLim', yl, 'XLim', xl);

function h = equalLine(varargin)

big = 1e10;
h = plot([-big, big], [-big, big], ...
    'Color', [0.5 0.5 0.5], varargin{:}, 'YLimInclude', 'off', 'XLimInclude', 'off');
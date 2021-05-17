function h = eyeline(varargin)

p = inputParser();
p.addParameter('slope', 1, @isscalar);
p.addParameter('offset', 0, @isscalar);
p.KeepUnmatched = true;
p.parse(varargin{:});

xl = xlim();

xd = diff(xl);
xv = xl;
xv(1) = xv(1) - 5*xd;
xv(2) = xv(2) + 5*xd;
yv = p.Results.slope*xv + p.Results.offset;

was_holding = ishold();
hold on;

h = plot(xv, yv, ...
    'Color', [0.5 0.5 0.5], 'XLimInclude', 'off', 'YLimInclude', 'off', p.Unmatched);
set(get(get(h, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');

if ~was_holding
    hold off;
end

end

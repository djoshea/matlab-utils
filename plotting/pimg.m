function [h, hcbar] = pimg(m, varargin)
% visualize an RGB image but with a referenced x and y
p = inputParser();
p.addParameter('x', [], @(x) isempty(x) ||  isvector(x));
p.addParameter('y', [], @(x) isempty(x) || isvector(x));
p.addParameter('dx', NaN, @isscalar);
p.addParameter('dy', NaN, @isscalar);
p.addParameter('addColorbar', true, @islogical);
p.addParameter('colorAxisLabel', '', @isstringlike);
p.parse(varargin{:});

% add an extra row onto m
addRowCol = @(v) [v, v(:, end)+diff(v(:, end-1:end), 1, 2); ...
    v(end, :) + diff(v(end-1:end, :), 1, 1), 2*v(end, end)-v(end-1, end-1)];

if isempty(p.Results.x)
    x = 0.5:size(m, 2)-0.5;
else
    x = p.Results.x;
    if isnan(p.Results.dx)
        dx = median(diff(x));
    else
        dx = p.Results.dx;
    end
    x = x - dx/2;
end
if isempty(p.Results.y)
    y = 0.5:size(m, 1)-0.5;
else
    y = p.Results.y;
    if isnan(p.Results.dy)
        dy = median(diff(y));
    else
        dy = NaN;
    end
    y = y - dy/2;
end

[X, Y] = meshgrid(x, y);
        
% need an extra row and column because of the way that pcolor works
m = addRowCol(m);
X = addRowCol(X);
Y = addRowCol(Y);

h = pcolor(X,Y, m);

set(h, 'EdgeColor', 'none');
%colormap(parula);
% colormap(flipud(cbrewer('div', 'RdYlBu', 256)));
% colormap(pmkmp(256));
%colormap gray;
TrialDataUtilities.Color.cmocean('haline');

if p.Results.addColorbar
    hcbar = colorbar;
    box(hcbar, 'off');
    set(hcbar, 'TickLength', 0);
    
    colorAxisLabel = string(p.Results.colorAxisLabel);
    if colorAxisLabel ~= ""
        hcbar.YLabel.String = colorAxisLabel;
    end
else
    hcbar = [];
end

box off
axis ij
axis on;

axis on;
set(gca, 'TickLength', [0 0], 'XAxisLocation', 'top');
axis tight;
box on;


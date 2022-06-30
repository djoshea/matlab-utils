function [h, hcbar] = pmat(m, varargin)
% visualize a matrix using pcolor

p = inputParser();
p.addParameter('x', [], @(x) isempty(x) ||  isvector(x));
p.addParameter('y', [], @(x) isempty(x) || isvector(x));
p.addParameter('dx', NaN, @isscalar);
p.addParameter('dy', NaN, @isscalar);
p.addParameter('addColorbar', true, @islogical);
p.addParameter('colorAxisLabel', '', @isstringlike);
p.addParameter('nanColor', [], @(x) true);
p.addParameter('transpose', false, @islogical);
p.parse(varargin{:});

% cla;

m = squeeze(m);

if isvector(m)
    m = repmat(makerow(m), 2, 1);
end

if islogical(m)
    m = double(m);
end

if ndims(m) > 2
    warning('Selecting (:, :, 1) of tensor to display');
    m = m(:, :, 1);
end

if p.Results.transpose
    m = m';
end

% add an extra row onto m
addRowCol = @(v) [v, v(:, end)+diff(v(:, end-1:end), 1, 2); ...
    v(end, :) + diff(v(end-1:end, :), 1, 1), 2*v(end, end)-v(end-1, end-1)];

if isempty(p.Results.x)
    x = 0.5:size(m, 2)-0.5;
    dx = 1;
else
    x = p.Results.x;
    if isnan(p.Results.dx)
        dx = median(diff(x));
    else
        dx = p.Results.dx;
    end
    if numel(x) == size(m, 2) + 1
        % x defines bin edges --> convert to left edges
        x = x(1:end-1);
    else
        % x defines centers, convert to left edges
        x = x - dx/2;
    end
end
if isempty(p.Results.y)
    y = 0.5:size(m, 1)-0.5;
    dy = 1;
else
    y = p.Results.y;
    if isnan(p.Results.dy)
        dy = median(diff(y));
    else
        dy = NaN;
    end
    if numel(y) == size(m, 1) + 1
        % y defines bin edges --> convert to bottom edges
        y = y(1:end-1);
    else
        y = y - dy/2;
    end
end

[X, Y] = meshgrid(x, y);
        
% need an extra row and column because of the way that pcolor works
m = addRowCol(m);
X = addRowCol(X);
Y = addRowCol(Y);

h = pcolor(X,Y, m);

set(h, 'EdgeColor', 'none');

if any(isnan(m))
    if isempty(p.Results.nanColor)
        h.AlphaData = ~isnan(m);
    else
        nanColor = p.Results.nanColor;
        nanImg = nan([size(m,1)-1, size(m,2)-1, 3]);
        nanImg(:, :, 1) = nanColor(1);
        nanImg(:, :, 2) = nanColor(2);
        nanImg(:, :, 3) = nanColor(3);
        
        washolding = ishold;
        hold on;
        hnan = image(x(1)+dx/2, y(1)+dy/2, nanImg);
        hnan.AlphaData = isnan(m(1:end-1, 1:end-1));
        if ~washolding
            hold off;
        end
    end
end
%colormap(parula);
% colormap(flipud(cbrewer('div', 'RdYlBu', 256)));
% colormap(pmkmp(256));
%colormap gray;
% TrialDataUtilities.Color.cmocean('haline');
TrialDataUtilities.Colormaps.mako();

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
set(gca, 'TickLength', [0 0], 'XAxisLocation', 'bottom');
axis tight;
box on;


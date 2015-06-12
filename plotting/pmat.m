function [h, hcbar] = pmat(varargin)
% visualize a matrix using pcolor

if(length(varargin) == 1)
    m = varargin{1};
else
    x = varargin{1};
    y = varargin{2};
    m = varargin{3};
end

cla;

m = squeeze(m);

if isvector(m)
    m = repmat(makerow(m), 2, 1);
end

if islogical(m)
    m = double(m);
end

% add an extra row onto m
addRowCol = @(v) [v, v(:, end)+diff(v(:, end-1:end), 1, 2); ...
    v(end, :) + diff(v(end-1:end, :), 1, 1), 2*v(end, end)-v(end-1, end-1)];

if nargin == 1
    x = 1:size(m, 2);
    y = 1:size(m, 1);
end

if isvector(x)
    [X, Y] = meshgrid(x, y);
else
    X = x;
    Y = y;
end
        
m = addRowCol(m);
X = addRowCol(X);
Y = addRowCol(Y);

h = pcolor(X,Y, m);

set(h, 'EdgeColor', 'none');
colormap(flipud(cbrewer('div', 'RdYlBu', 256)));
%colormap gray;

hcbar = colorbar;
box(hcbar, 'off');
set(hcbar, 'TickLength', [0]);

box off
axis ij
axis on;

if size(m, 1) > 50 || size(m, 2) > 50
    return;
end
x = X(1, :);
y = Y(:, 1);
xTick = x(1:end-1) + diff(x) / 2;
xTickLabels = arrayfun(@num2str, x(1:end-1), 'UniformOutput', false);
yTick = y(1:end-1) + diff(y) / 2;
yTickLabels = arrayfun(@num2str, y(1:end-1), 'UniformOutput', false);

set(gca, 'XAxisLocation', 'top', 'TickLength', [0 0]);
set(gca, 'XTick', xTick, 'XTickLabel', xTickLabels, ...
    'YTick', yTick, 'YTickLabel', yTickLabels);

axis on;



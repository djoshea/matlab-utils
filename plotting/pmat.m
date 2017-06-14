function [h, hcbar] = pmat(m, varargin)
% visualize a matrix using pcolor

p = inputParser();
p.addParamValue('x', [], @(x) isvector(x));
p.addParamValue('y', [], @(x) isvector(x));
p.addParamValue('xlabel', {}, @(x) isvector(x) || iscellstr(x));
p.addParamValue('ylabel', {}, @(x) isvector(x) || iscellstr(x));
p.addParameter('addColorbar', true, @islogical);
p.parse(varargin{:});

cla;

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

% add an extra row onto m
addRowCol = @(v) [v, v(:, end)+diff(v(:, end-1:end), 1, 2); ...
    v(end, :) + diff(v(end-1:end, :), 1, 1), 2*v(end, end)-v(end-1, end-1)];

if isempty(p.Results.x)
    x = 0.5:size(m, 2)-0.5;
else
    x = p.Results.x;
end
if isempty(p.Results.y)
    y = 0.5:size(m, 1)-0.5;
else
    y = p.Results.y;
end

[X, Y] = meshgrid(x, y);
        
m = addRowCol(m);
X = addRowCol(X);
Y = addRowCol(Y);

h = pcolor(X,Y, m);

set(h, 'EdgeColor', 'none');
colormap(parula);
% colormap(flipud(cbrewer('div', 'RdYlBu', 256)));
%colormap(pmkmp(256));
%colormap gray;
if p.Results.addColorbar
    hcbar = colorbar;
    box(hcbar, 'off');
    set(hcbar, 'TickLength', 0);
end

box off
axis ij
axis on;

x = X(1, :);
y = Y(:, 1);
showX = size(m, 2) < 20;
showY = size(m, 1) < 20;
xRot = 0;
xTick = x(1:end-1) + diff(x) / 2;
if isempty(p.Results.xlabel)
    xTickLabels = arrayfun(@num2str, xTick, 'UniformOutput', false);
else
    showX = true;
    xRot = 45;
    xTickLabels = p.Results.xlabel;
    if isnumeric(xTickLabels)
        xTickLabels = arrayfun(@num2str, xTickLabels, 'UniformOutput', false);
    end
end
if showX
    set(gca, 'XTick', xTick, 'XTickLabel', xTickLabels, 'XTickLabelRotation', xRot);
end

set(gca, 'XAxisLocation', 'top');

yTick = y(1:end-1) + diff(y) / 2;
if isempty(p.Results.ylabel)
    yTickLabels = arrayfun(@num2str, yTick, 'UniformOutput', false);
else
    showY = true;
    yTickLabels = p.Results.ylabel;
    if isnumeric(yTickLabels)
        yTickLabels = arrayfun(@num2str, yTickLabels, 'UniformOutput', false);
    end
end
if showY
    set(gca, 'YTick', yTick, 'YTickLabel', yTickLabels);
end
axis on;
set(gca, 'TickLength', [0 0], 'XAxisLocation', 'top');
axis tight;
box on;



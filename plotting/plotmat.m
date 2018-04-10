function h = plotmat(varargin)
% visualize a matrix using pcolor

if nargin == 1
    m = varargin{1};
    x = 1:size(m, 2);
    y = 1:size(m, 1);
else
    x = varargin{1};
    y = varargin{2};
    m = varargin{3};
end
    
cla;
m = squeeze(m);

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

dx = x(2) - x(1);
dy = y(2) - y(1);

[X, Y] = meshgrid(x, y);
        
% need an extra row and column because of the way that pcolor works
m = addRowCol(m);
X = addRowCol(X);
Y = addRowCol(Y);

h = pcolor(X-dx/2,Y-dy/2, m);

set(h, 'EdgeColor', 'none');
colormap(pmkmp(256));
box off
axis ij
axis on;
axis tight;


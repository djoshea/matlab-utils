function [h hcbar] = pmat(varargin)
% visualize a matrix using pcolor

if(length(varargin) == 1)
    m = varargin{1};
else
    x = varargin{1};
    y = varargin{2};
    m = varargin{3};
end

cla;

if isvector(m)
    m = repmat(makerow(m), 2, 1);
end

if islogical(m)
    m = double(m);
end

if nargin == 1
    h = pcolor(m);
else
    if isvector(x)
        [x y] = ndgrid(x, y);
    end
        
    h = pcolor(x,y, m);
end
set(h, 'EdgeColor', 'none');
%colormap(flipud(cbrewer('div', 'RdYlBu', 256)));
%colormap gray;

hcbar = colorbar;

box off
axis ij

set(gca, 'XAxisLocation', 'top');


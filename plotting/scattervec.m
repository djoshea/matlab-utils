function scattervec(x, y, varargin)

scatter(vec(x), vec(y), 40, 'filled', varargin{:});
niceGrid;
axis equal;
eyeline

end


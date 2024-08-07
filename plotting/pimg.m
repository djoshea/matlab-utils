function hh = pimg(m, varargin)
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
addRowCol = @(v) [v, v(:, end, :)+diff(v(:, end-1:end, :), 1, 2); ...
    v(end, :, :) + diff(v(end-1:end, :, :), 1, 1), 2*v(end, end, :)-v(end-1, end-1, :)];

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

% taken from inside pcolor
cax = newplot();
nextPlot = cax.NextPlot;

hh = surface(X, Y, zeros(size(m, [1 2])), m);
if iscategorical(x)
    xlims = makeCategoricalLimits(x);
else
    xlims = [min(min(x)) max(max(x))];
end
if iscategorical(y)
    ylims = makeCategoricalLimits(y);
else
    ylims = [min(min(y)) max(max(y))];
end
set(hh,'AlignVertexCenters','on', 'EdgeColor', 'none');

if ismember(nextPlot, {'replace','replaceall'})
    set(cax,'View',[0 90]);
    set(cax,'Box','on');
    if ~iscategorical(xlims) && xlims(2) <= xlims(1)
        xlims(2) = xlims(1)+1;
    end
    if ~iscategorical(ylims) &&  ylims(2) <= ylims(1)
        ylims(2) = ylims(1)+1;
    end
    xlim(cax, xlims);
    ylim(cax, ylims);

    axis ij
    axis on;
    
    set(gca, 'TickLength', [0 0], 'XAxisLocation', 'top');
    axis tight;
    box on;
end

end

function categoricalLimits = makeCategoricalLimits(x)
    % Convert the categories to double, estimate limits
    % Convert the doubles back to categorical, restoring
    % the original categories
    cats = categories(x);
    x_d = double(x);
    xlims_d = [min(min(x_d)), max(max(x_d))];
    categoricalLimits = categorical(cats(xlims_d), cats);
end




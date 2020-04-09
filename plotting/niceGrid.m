function niceGrid(ax)

    if nargin < 1
        ax = gca;
    end

    % use a dark background with light grid lines
    ax.Color = [0.92 0.92 0.95];
    ax.GridColor = [1 1 1];
    ax.GridAlpha = 1;
    ax.GridLineStyle = '-';
    ax.MinorGridColor =  [0.96 0.96 0.96];
    ax.MinorGridAlpha = 1;
    ax.MinorGridLineStyle = '-';
    ax.TickDir = 'out';
    grid(ax, 'on');
    
    figh = getParentFigure(ax);
    figh.InvertHardcopy = 'off';
    
    box(ax, 'off');

end


function fig = getParentFigure(axh)
    % if the object is a figure or figure descendent, return the
    % figure. Otherwise return [].
    fig = axh;
    while ~isempty(fig) && ~isa(fig, 'matlab.ui.Figure') % ~strcmp('figure', get(fig,'type'))
      fig = get(fig,'Parent');
    end
end

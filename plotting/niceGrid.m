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
    
    grid(ax, 'on');

end
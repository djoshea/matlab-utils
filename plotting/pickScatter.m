function idx = pickScatter(s)
    if nargin < 1
        ax = gca;
        s = findobj(ax.Children, 'Type', 'scatter');
        if isempty(s)
            error('No scatter plot found in current axis');
        end
    end
    x = s.XData';
    y = s.YData';
    
    g = ginput(1);
    D = pdist2([x y],g);
    [~,idx] = min(D); 
end
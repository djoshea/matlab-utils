function [hBar hLine] = barWithError(x, y, e, w, color, varargin)

    x = makecol(x);
    y = makecol(y);
    e = makecol(e);
   
    origHold = ishold;

    hold on
    hBar = bar(x,y,w, 'FaceColor', color, 'EdgeColor', 'none');
    delete(get(hBar, 'Baseline'));

    plot([x'; x'], [y'; y'+sign(y').*e'], 'Color', color, 'LineWidth', 2)

    if ~origHold
        hold off
    end

end

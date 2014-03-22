function [hPts, hLine] = errorline(x,y,e, varargin)
% like errorbar, except plots vertical lines that look nice 

    marker = '.';
    lineWidth = 1;
    color = 'k';
    axh = [];
    assignargs(varargin);

    x = makecol(x);
    y = makecol(y);
    e = makecol(e);
   
    if isempty(axh)
        axh = gca;
    end

    hPts = plot(x,y, marker, 'Parent', axh, 'Color', color, ...
        'MarkerFaceColor', color, 'MarkerEdgeColor', color);

    origHold = ishold(axh);
    hold(axh, 'on');

    hLine = plot([x'; x'], [y'-e'; y'+e'], 'Parent', axh, ...
        'Color', color, 'LineWidth', lineWidth);

    if ~origHold
        hold(axh, 'off');
    end
end

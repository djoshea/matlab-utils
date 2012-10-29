function [width height] = getFigSize(figh)

% set to auto so its saved at this size too
set(gcf, 'PaperPositionMode', 'auto');

units = get(gcf, 'Units');
set(gcf, 'Units', 'pixels');
pos = get(gcf, 'Position');
set(gcf, 'Units', units);

width = pos(3);
height = pos(4);

end

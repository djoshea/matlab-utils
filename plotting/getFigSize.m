function [width, height] = getFigSize(figh)

if nargin < 1    
    figh = gcf;
end
% set to auto so its saved at this size too
set(figh, 'PaperPositionMode', 'auto');

units = get(figh, 'Units');
set(figh, 'Units', 'centimeters');
pos = get(figh, 'Position');
set(figh, 'Units', units);

scale = getFigureSizeScale();
width = pos(3) / scale;
height = pos(4) / scale;

end

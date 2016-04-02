function sz = figSize(newSize, figh, undock)
% figsize([width height], figh)
% figsize([width height]) - uses gcf by default
% 
% Sizes figure to height x width in cm

if nargin < 2
    figh = gcf;
end
if nargin < 3
    undock = false;
end
    
% return current figsize as [w h] in cm
if nargin == 0
    set(figh, 'PaperUnits' ,'centimeters');
    set(figh, 'Units', 'centimeters');
    figPos = get(figh,'Position');
    sz = [figPos(3), figPos(4)];
    return;
end

% undock figure
if undock
    set(figh, 'WindowStyle', 'normal');
end
drawnow;

set(figh, 'PaperUnits' ,'centimeters');
set(figh, 'Units', 'centimeters');
figPos = get(figh,'Position');

set(figh, 'PaperPositionMode', 'auto');
newPos = [figPos(1), figPos(2), newSize];

if ~strcmp(get(figh, 'WindowStyle'), 'docked')
    set(figh, 'Position', newPos);
end

sz = newSize;

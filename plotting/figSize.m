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
    
set(figh, 'PaperUnits' ,'centimeters');
set(figh, 'Units', 'centimeters');
figPos = get(figh,'Position');
sz = [figPos(3), figPos(4)];

% return current figsize as [w h] in cm
if nargin == 0
    return;
end

assert(numel(newSize) == 2, 'New size must be [width height] vector');

% undock figure
if undock
    set(figh, 'WindowStyle', 'normal');
end
drawnow;

if any(isnan(newSize))
    % set other dimension to preserve aspect ratio
    if all(isnan(newSize))
        error('Must specify at least one of width or height');
    end
    
    aspectHOverW = sz(2) / sz(1);
    
    if isnan(newSize(1))
        % compute width
        newSize(1) = newSize(2) / aspectHOverW;
    else
        newSize(2) = newSize(1) * aspectHOverW;
    end
end
        
set(figh, 'PaperUnits' ,'centimeters');
set(figh, 'Units', 'centimeters');
figPos = get(figh,'Position');

set(figh, 'PaperPositionMode', 'auto');
newPos = [figPos(1), figPos(2), newSize];

if ~strcmp(get(figh, 'WindowStyle'), 'docked')
    set(figh, 'Position', newPos);
end

sz = newSize;

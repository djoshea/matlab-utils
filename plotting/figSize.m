function sz = figSize(newSize, figh, varargin)
% figsize([width height], figh)
% figsize([width height]) - uses gcf by default
% 
% Sizes figure to height x width in cm


if nargin < 2
    figh = gcf;
end

p = inputParser();
p.addParameter('undock', true, @islogical);
p.addParameter('paperPositionMode', 'auto', @ischar);
p.parse(varargin{:});

set(figh, 'PaperUnits' ,'centimeters');
set(figh, 'Units', 'centimeters');
figPos = get(figh(1),'Position');
sz = [figPos(3), figPos(4)];

% return current figsize as [w h] in cm
if nargin == 0
    return;
end

assert(numel(newSize) == 2, 'New size must be [width height] vector');

% undock figure
if p.Results.undock
    set(figh, 'WindowStyle', 'normal');
end

% force refresh
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
figPos = get(figh(1),'Position');

set(figh, 'PaperPositionMode', p.Results.paperPositionMode);
newPos = [figPos(1), figPos(2), newSize];

isDocked =  strcmp(get(figh, 'WindowStyle'), 'docked');

for i = 1:numel(figh)
    if ~isDocked(i)
        set(figh(i), 'Position', newPos);
    end

    if isDocked(i) || strcmp(p.Results.paperPositionMode, 'manual')
        set(figh(i), 'PaperPosition', newPos);
    end
end

sz = newSize;

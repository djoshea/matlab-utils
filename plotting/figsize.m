function figsize(varargin)
% figsize(figh, height, width)
% figh(height, width) - uses gca

if(nargin == 3)
    figh = varargin{1};
    height = varargin{2};
    width = varargin{3};
elseif(nargin == 2)
    figh = gcf;
    height = varargin{1};
    width = varargin{2};
else
    error('Requires 2 or 3 arguments: [figh=gcf], height, width');
end

figurePaperUnits = get(figh, 'PaperUnits');
oldFigureUnits = get(figh, 'Units');
oldFigPos = get(figh,'Position');
set(figh, 'Units', figurePaperUnits);
figPos = get(figh,'Position');
refsize = figPos(3:4);

aspectRatio = refsize(1)/refsize(2);
wscale = width/refsize(1);
hscale = height/refsize(2);
sizescale = min(wscale,hscale);

set(figh, 'PaperPositionMode', 'auto');
newPos = [figPos(1) figPos(2)+figPos(4)*(1-hscale) ...
    wscale*figPos(3) hscale*figPos(4)];
set(figh, 'Position', newPos);
set(figh, 'Units', oldFigureUnits);

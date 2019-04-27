function whiteOnGreyGrid(axh, mode, varargin)

p = inputParser();
p.addParameter('xMinor', false, @islogical);
p.addParameter('yMinor', false, @islogical);
p.parse(varargin{:});

if nargin < 1
    axh = gca;
end
if nargin < 2
    mode = 'xy';
end

switch mode
    case 'x'
        axh.XGrid = 'on';
        axh.YGrid = 'off';

    case 'y'
        axh.XGrid = 'off';
        axh.YGrid = 'on';

    case {'both', 'xy'}
        axh.XGrid = 'on';
        axh.YGrid = 'on';

    otherwise
        error('Mode must be x, y, or xy');
end

if p.Results.xMinor
    axh.XMinorGrid = 'on';
else
    axh.XMinorGrid = 'off';
end
if p.Results.yMinor
    axh.YMinorGrid = 'on';
else
    axh.YMinorGrid = 'off';
end

gridBackground = [0.92 0.92 0.95]; % copying Seaborn
gridColor = 'w';
minorGridColor = [0.96 0.96 0.96];

axh.Color = gridBackground;
axh.GridColor = gridColor;
axh.GridAlpha = 1;
axh.MinorGridColor = minorGridColor;
axh.MinorGridAlpha = 1;
axh.MinorGridLineStyle = '-';

figh = getParentFigure(axh);
figh.InvertHardcopy = 'off';

end

function fig = getParentFigure(axh)
    % if the object is a figure or figure descendent, return the
    % figure. Otherwise return [].
    fig = axh;
    while ~isempty(fig) && ~isa(fig, 'matlab.ui.Figure') % ~strcmp('figure', get(fig,'type'))
      fig = get(fig,'Parent');
    end
end
function prepfig(varargin)
% sets units to centimeters
% set tick lengths to be 1 mm
% set font-sizes to be at least 14

figsize(varargin{:});

if(nargin == 1)
    figh = varargin{1};
else
    figh = gcf;
end

set(figh, 'PaperUnits' ,'centimeters');
set(figh, 'Units', 'centimeters');
set(figh, 'PaperPositionMode', 'auto');

axh = findall(figh,'type','axes');
set(axh, 'Units', 'centimeters');

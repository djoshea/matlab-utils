function drawArrow(x,y, varargin)
p = inputParser();
p.addParamValue('color', 'k', @(x) true);
p.KeepUnmatched = true;
p.parse(varargin{:});

line(x, y, 'Color', p.Results.color, p.Unmatched);

%[figx figy] = dsxy2figxy(x, y);
%annotation('arrow', figx, figy, 'HeadStyle', headStyle, 'Color', color);


end

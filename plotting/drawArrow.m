function drawArrow(x,y, varargin)
color = 'k';
headStyle = 'vback1';
assignargs(varargin);

line(x, y, 'Color', color);

%[figx figy] = dsxy2figxy(x, y);
%annotation('arrow', figx, figy, 'HeadStyle', headStyle, 'Color', color);


end

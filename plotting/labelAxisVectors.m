function labelAxisVectors(varargin)

% for now assume 3d
%

frac = 1;
labels = {'X', 'Y', 'Z'};
width = 2;

A = view;
xv = A*[1 0 0 0]';
yv = A*[0 1 0 0]';
zv = A*[0 0 1 0]';

p0 = [0.1 0.1]';
xv = xv ./ norm(xv) * 0.1;
yv = yv ./ norm(yv) * 0.1;
zv = zv ./ norm(zv) * 0.1;

xf = p0 + xv(1:2);
yf = p0 + yv(1:2);
zf = p0 + zv(1:2);

% draw the arrows
annotation('line', [p0(1) xf(1)], [p0(2) xf(2)]);
annotation('line', [p0(1) yf(1)], [p0(2) yf(2)]);
annotation('line', [p0(1) zf(1)], [p0(2) zf(2)]);

% draw the labels
h.xlabel = annotation('textbox', xf, 'String', labels{1});
h.ylabel = annotation('textbox', yf, 'String', labels{2});
h.zlabel = annotation('textbox', zf, 'String', labels{3}); 

end

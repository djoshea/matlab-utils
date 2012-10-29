function pmat(m)
% visualize a matrix using pcolor

if isvector(m)
    m = repmat(makerow(m), 2, 1);
end
h = pcolor(m);
set(h, 'EdgeColor', 'none');
colormap gray;

box off


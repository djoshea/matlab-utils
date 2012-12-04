function pmat(m)
% visualize a matrix using pcolor

clf;

if isvector(m)
    m = repmat(makerow(m), 2, 1);
end
h = pcolor(m);
set(h, 'EdgeColor', 'none');
%colormap(flipud(cbrewer('div', 'RdYlBu', 256)));
%colormap gray;

colorbar;

box off


function plot_cols_stem(U)

C = size(U, 2);
% U = U ./ max(abs(U(:)));
U = U ./ max(abs(U), [], 1);

offsets = -2.05 * (0:C-1);

for iC = 1:C
    drawstem(U(:,iC),  offsets(iC));
end

axis tight
axis off;
hold off;

end

function drawstem(v, base)
    x = 1:numel(v);
    plot(x, v + base, 'o', 'MarkerSize', 6, ...
        'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none');
    line([x; x], [repmat(base, 1, numel(v)); v' + base], 'Color', 'k');
    hold on;
    yline(base);
end
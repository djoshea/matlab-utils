function plotEigs(A, scatter_args, args)

    arguments
        A (:, :) double
        scatter_args.?matlab.graphics.chart.primitive.Scatter
        args.showCircle = true;
        args.markerSize = 5;
    end

    scale = getFigureSizeScale();

if args.showCircle
    t = linspace(0, 360, 1000);
    plot(cos(t), sin(t), '-', 'LineWidth', 0.25*scale, 'Color', grey(0.5));
    hold on;
end

eA = eig(A);
scatter_args = namedargs2cell(scatter_args);
scatter(real(eA), imag(eA), args.markerSize*scale, "MarkerFaceAlpha", 0.8, ...
    "MarkerEdgeColor", "none", "MarkerFaceColor", "k", scatter_args{:});
axis equal;
hold off;
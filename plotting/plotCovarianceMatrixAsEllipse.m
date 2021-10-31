function h = plotCovarianceMatrixAsEllipse(sigma, varargin)
    [V, D] = eig(sigma);

    t = linspace(0, 2*pi, 100);
    xy = V * (sqrt(diag(D)) .* [cos(t); sin(t)]);

    h = plot(xy(1, :), xy(2, :), varargin{:});
end

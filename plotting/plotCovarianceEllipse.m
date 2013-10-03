function [ellipseX, ellipseY] = plotCovarianceEllipse(x, y, varargin)
    C = cov(x,y);
    muX = mean(x);
    muY = mean(y);

    n=100; % Number of points around ellipse
    p=0:pi/n:2*pi; % angles around a circle

    [eigvec,eigval] = eig(C); % Compute eigen-stuff
    xy = [cos(p'),sin(p')] * sqrt(eigval) * eigvec'; % Transformation
    ellipseX = xy(:,1) + muX;
    ellipseY = xy(:,2) + muY;

    plot(ellipseX, ellipseY, varargin{:});
end
        
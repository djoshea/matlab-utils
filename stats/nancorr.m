function [rho, pval] = nancorr(x, y, varargin)

    x = makecol(x(:));
    y = makecol(y(:));
    mask = ~isnan(x) & ~isnan(y);

    [rho, pval] = corr(x(mask), y(mask), varargin{:});

end
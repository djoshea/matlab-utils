function [rho, pval] = nancorr(x, y, varargin)

    x = makecol(x(:));
    y = makecol(y(:));
    mask = ~isnan(x) & ~isnan(y);

    if any(mask)
        [rho, pval] = corr(x(mask), y(mask), varargin{:});
    else
        rho = NaN;
        pval = NaN;
    end

end
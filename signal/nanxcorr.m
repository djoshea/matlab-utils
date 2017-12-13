function [c, lags] = nanxcorr(x, y, maxlag)
    assert(isvector(x) && isvector(y));
    x = makecol(x);
    y = makecol(y);
    m = size(x,1);
    n = size(y,1);
    maxmn = max(m,n);
    
    if nargin < 3
        maxlag = maxmn - 1;
    end

    mxl = min(maxlag,maxmn - 1);
    nc = 2*mxl + 1;
    
    c = zeros(nc,1);
    lags = (-maxlag:maxlag)';
    
    % coder.internal.conjtimes(x,y) is used below to evaluate conj(x)*y. It
    % tends to produce slightly better generated code in some cases, and it has
    % the benefit of handling the case where x is logical.
    for k = 0:mxl
        ihi = min(m - k,n);
        s = 0;
        nNonNaN = 0;
        for i = 1:ihi
            if isnan(y(i)) || isnan(x(k+i))
                continue;
            end
            nNonNaN = nNonNaN+1;
            s = s + conj(y(i))*x(k + i);
        end
        c(mxl + k + 1) = s / nNonNaN * (mxl+1);
    end
    
    for k = 1:mxl
        ihi = min(m,n - k);
        s = 0;
        nNonNaN = 0;
        for i = 1:ihi
            if isnan(y(k+i)) || isnan(x(i))
                continue;
            end
            nNonNaN = nNonNaN+1;
            s = s + conj(y(k + i))*x(i);
        end
        c(mxl - k + 1) = s / nNonNaN * (mxl+1);
    end
end

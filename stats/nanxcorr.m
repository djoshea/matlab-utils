function [c, lags] = nanxcorr(a,b,varargin)

asc = (a - nanmean(a)) / nanstd(a);
asc(isnan(a)) = 0;
bsc = (b - nanmean(b)) / nanstd(b);
bsc(isnan(b)) = 0;

[c, lags] = xcorr(asc, bsc);

end
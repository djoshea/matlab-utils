function tso = removeNaNs(tsin)

% tso = removeNaNs(tsa)
% removes all times where all components of the data of tsin is nan
%
% ADR v6.0 2011/12

T = tsin.range();
D = tsin.data();
dim = size(D);
D = reshape(D, length(T), prod(dim(2:end)));
keep = ~all(isnan(D),2);
tso = tsd(T(keep), tsin.data(T(keep)));
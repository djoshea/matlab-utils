function tso = keep(tsin, keep)

% tso = keep(tsin, OK)
% returns a new tsd with only the elements in OK
%
% ADR v6.0 2011/12

T = tsin.range();
D = tsin.data();
dim = size(D);
D = reshape(D, length(T), prod(dim(2:end)));
tso = tsd(T(keep), tsin.data(T(keep)));
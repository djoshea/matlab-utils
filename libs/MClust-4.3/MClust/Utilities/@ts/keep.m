function tso = keep(tsin, keep)

% tso = keep(tsin, OK)
% returns a new tsd with only the elements in OK
%
% ADR v6.0 2011/12

T = tsin.range();
tso = ts(T(keep));
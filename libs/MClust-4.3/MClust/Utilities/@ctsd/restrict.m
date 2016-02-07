function tso = restrict(tsin, t0 ,t1)

% 	R = Restrict(tsa, t0, t1)
% 	Returns a new tsa (ts) R so that only D.Data is between 
%		timestamps t0 and t1, where t0 and t1 are in units
%
%   If units are not specified, assumes t has same units as D
%   t0 and t1 can be arrays
%
% ADR 2011
% version L6.0
% converts to tsd and uses that

tso = tsd(tsin);
tso = restrict(tso, t0, t1);

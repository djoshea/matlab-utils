function R = restrict(tsa, t0, t1)

% 	R = Restrict(tsa, t0, t1)
% 	Returns a new tsa (ts) R so that only D.Data is between 
%		timestamps t0 and t1, where t0 and t1 are in units
%
%   If units are not specified, assumes t has same units as D
%   t0 and t1 can be arrays
%
% ADR 2011
% version L6.0

if nargin < 3
	error('ts:MismatchedRestrict','Use data for finding closest samples.')
end

if length(t0) ~= length(t1)
	error('ts:MismatchedRestrict','t0 and t1 must be same length')
end

keep = false(size(tsa.T));

for iT = 1:length(t0)
	keep = keep | (tsa.T >= t0(iT) & tsa.T <= t1(iT));	
end

R = ts(tsa.T(keep));


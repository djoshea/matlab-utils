function X = mask(tsa, t0, t1, masking)
%
% mTSD = ctsd/Mask(tsd, t0, t1, masking)
%
% INPUTS:
%    X = tsd object
%    t0 = sets of start times
%    t1 = sets of end times
%    masking = 1=NaN times inside trial pairs, 0=NaN times outside trial
%          pairs (default = 1)
%    NOTE: must be SAME units as tsd!
%
% OUTPUTS:
%    mtsd = tsd object with times (not) in TrialPairs set to NaN
%
% ADR 1998
% version L6.0 
% ADR Jan/2007 - incorporated with posneg
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.5.
% Version control M3.5.

if nargin==3
	masking = true;
end

assert(length(t0) == length(t1), 't0 and t1 must be same length');

T = tsa.range;
D = tsa.data;

keep = false(size(T));
for iM = 1:length(t0)
	keep(T >= t0(iM) & T <= t1(iM)) = true;
end

% select along first dimension
shape = size(D);
D = reshape(D, [shape(1), prod(shape(2:end))]);
if masking
	D(keep,:) = NaN;
else %not posneg
	D(~keep,:) = NaN;
end	
D = reshape(D, [size(D,1), prod(shape(2:end))]);

X = tsd(T, D);

function [d,ix] = data(tsa, tlist, varargin)
%
% [d,ix] = data(tsa)
% returns tsa.t
%
% d = data(tsa, tlist)
% returns the nearest elements to tlist in tsa
%
% d = data(tsa, tlist, parms)
% allows control of parameters through process_varargin
%
% extrapolate = nan;   %% if 0 then only include tlist values such that
%                      %%   starttime(t) >= tlist <= endtime(t)
%                      %% if 1 then tlist values outside tsa's range
%                      %%   are returned as the endpoints of tsa
%                      %% if nan then tlist values outside tsa's range
%                      %%   are returned as nan
% ADR v6.0 2011/12

extrapolate = nan;
process_varargin(varargin);

if nargin > 1 && isa(tlist, 'ts')
	tlist = tlist.range();
end

if nargin==1
	d = tsa.T;
else
	if size(tlist,1)==1, tlist = tlist'; end
	nT = length(tsa.T);
	ix = round(interp1q(tsa.T, (1:nT)', tlist));
	
	if isnan(extrapolate)
		in_range = ix >= 1 & ix <= nT;	
		d = nan(size(ix));
		d(in_range) = tsa.T(ix(in_range));		
	elseif extrapolate
		ix(tlist < tsa.T(1)) = 1;
		ix(tlist > tsa.T(end)) = nT;
		d = tsa.T(ix);
	else
		in_range = ix >= 1 & ix <= nT;
		ix = ix(in_range);
		d = tsa.T(ix);		
	end
end

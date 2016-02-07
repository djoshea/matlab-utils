function [d] = data(tsa, tlist, varargin)

%
% d = data(tsa)
% returns tsa.D
%
% d = data(tsa, tlist)
% returns the nearest elements to tlist in tsa
%
% d = data(tsa, tlist, parms)
% allows control of parameters through extract_varargin
%
% extrapolate = nan;   %% if 0 then only include tlist values such that
%                      %%   starttime(t) >= tlist <= endtime(t)
%                      %% if 1 then tlist values outside tsa's range
%                      %%   are returned as the endpoints of tsa
%                      %% if nan then tlist values outside tsa's range
%                      %%   are returned as nan
%
% ADR v6.0 2011/12
%
% ADR FIXED BUG in extrapolate==nan condition

extrapolate = nan;
process_varargin(varargin);

if nargin==1    
	d = tsa.D;
else
	if isa(tlist, 'ts')
		tlist = tlist.range();
	end
    t0 = tsa.starttime();
    t1 = tsa.endtime();   

    ix = round((tlist - t0)/tsa.dT+1);

    if isnan(extrapolate)
		in_range = tlist >= tsa.T0 & tlist <= t1;	
		ix(~in_range) = nan;		
	elseif extrapolate
		ix(tlist < t0) = 1;
		ix(tlist > t1) = tsa.nD();
	else
		in_range = tlist >= t0 & tlist <= t1;	
		ix = ix(in_range);
    end
    
    d = selectalongfirstdimension(tsa.D, ix);
end

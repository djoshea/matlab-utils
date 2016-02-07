function [d,ix] = data(tsa, tlist, varargin)

%
% d = data(tsa)
% returns tsa.D
%
% d = data(tsa, tlist)
% returns the nearest elements to tlist in tsa
%
% d = data(tsa, tlist, parms)
% allows control of parameters through process_varargin(varargin);
%
% extrapolate = nan;   %% if 0 then only include tlist values such that
%                      %%   starttime(t) >= tlist <= endtime(t)
%                      %% if 1 then tlist values outside tsa's range
%                      %%   are returned as the endpoints of tsa
%                      %% if nan then tlist values outside tsa's range
%                      %%   are returned as nan
%
% ADR v6.0 2011/12

extrapolate = nan;
process_varargin(varargin);

if nargin > 1 && isa(tlist, 'ts')
	tlist = tlist.range();
end

if nargin==1
	d = tsa.D;
else
    [~, ix] = data@ts(tsa, tlist, 'extrapolate', extrapolate);
    d = selectalongfirstdimension(tsa.D, ix);
end

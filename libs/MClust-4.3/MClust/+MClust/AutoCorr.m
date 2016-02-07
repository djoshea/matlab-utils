function [AC,xr] = AutoCorr(T, varargin)

% MClust.AutoCorr(T)
%
%
% INPUTS
%    T -- times of data (in seconds)
%
% OUTPUTS
%    AC --- tsd of autocorrelation of self
%
% ADR 2012
%
% Status: PROMOTED (Release version)
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M4.0.

axesHandle = [];
myFigureTag = 'AutoCorr';
myTitle = 'Autocorrelation';
binSize = 0.01; % in seconds
width = 0.5; %in seconds
process_varargin(varargin);

MCS = MClust.GetSettings();
if isa(T, 'ts')
	T = T.range();
end

xrange = 0:binSize:width;
nBins = length(xrange);
if isempty(T)
	AC = tsd(xrange, zeros(nBins,1));
	return;
end

[ACD,xrange] = MClustStats.AutoCorr(T, binSize, nBins);
AC = tsd(xrange, ACD);

if nargout == 0 || ~isempty(axesHandle)  % no output args, plot it
    
    if isempty(axesHandle)
        axesHandle = axes('Parent', figure('Tag', myFigureTag));
    end
    axes(axesHandle);
    bar(xrange, ACD, 'FaceColor', 'c');
    title(myTitle);
end
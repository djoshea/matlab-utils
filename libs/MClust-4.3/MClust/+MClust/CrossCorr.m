function [AC,xrange] = CrossCorr(T1, T2, varargin)

% MClust.CrossCorr(T1, T2)
%
%
% INPUTS
%    T1 -- times of data (in seconds)
%    T2 -- times of data (in seconds)
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
myFigureTag = 'CrossCorr';
myTitle = 'Crosscorrelation';
binSize = 0.001; % in seconds
width = 0.5; %in seconds
process_varargin(varargin);

MCS = MClust.GetSettings();
if isa(T1, 'ts'), T1 = T1.range(); end
if isa(T2, 'ts'), T2 = T2.range(); end

xrange = -width:binSize:width;
nBins = length(xrange);
if isempty(T1) || isempty(T2)
	AC = tsd(xrange, zeros(nBins,1));
	return;
end

[ACD,xrange] = MClustStats.CrossCorr(T1, T2, binSize, nBins);
AC = tsd(xrange, ACD);

if nargout == 0 || ~isempty(axesHandle)  % no output args, plot it
    
    if isempty(axesHandle)
        axesHandle = axes('Parent', figure('Tag', myFigureTag));
    end
    axes(axesHandle);
    bar(xrange, ACD, 'FaceColor', 'b', 'EdgeColor', 'b');
	title(myTitle);
	set(gca, 'XLim', [-width width]);
	
	yL = get(gca, 'YLim');
	line([0 0], yL, 'color', 'r');
end
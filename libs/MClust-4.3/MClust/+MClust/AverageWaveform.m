function [mWV, sWV, xrange] = AverageWaveform(WV,varargin)

% AverageWaveform(wv)
%
%
% INPUTS
%    wv -- tsd of tt or waveform data
%
% OUTPUTS
%    mWV - mean waveform 4 x 32
%    sWV - stddev waveform 4 x 32
%
%
% ADR 1998
%
% Status: PROMOTED (Release version)
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.
%
% modified by ncst 23 Apr 03 to be compatible with n samples
% (instead of 32)

axesHandle = [];
myFigureTag = 'AvgWV';
myTitle = 'Average Waveform';
showSE = true;
varargin = process_varargin(varargin);

MCS = MClust.GetSettings();
WVD = WV.data;

[nSpikes, nCh, nSamp] = size(WVD);

[x,y] = ndgrid(1:nSamp, 1:nCh);
xrange = x+nSamp*1.5*y;

if size(WVD,2)==1 % one channel MATLAB squeeze works WRONG
    mWV = squeeze(mean(WVD,1));
    sWV = squeeze(std(WVD,1,1));
else
    mWV = squeeze(mean(WVD,1))';
    sWV = squeeze(std(WVD,1,1))'; % ADR 2013-12-12 added flag correctly
end

if nargout == 0 || ~isempty(axesHandle)  % no output args, plot it
    
    if isempty(axesHandle)
        axesHandle = axes('Parent', figure('Tag', myFigureTag));
    end
    axes(axesHandle);
    plot(xrange, mWV, varargin{:});
	if showSE
		hold on;
		errorbar(xrange,mWV,sWV, varargin{:});
		hold off
	end
    axis off
    set(gca, 'YLim',MCS.AverageWaveform_ylim);
    title(myTitle);
end
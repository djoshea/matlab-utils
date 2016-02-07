function ClusterFunc_ShowWaveforms(self)

% ClusterFunc_ShowWaveforms(self)

% ADR 2012
% ADR 2013-12-12
%

%===============================================================
% PARAMETERS
%===============================================================

useSelfColor = true;

% GO

MCS = MClust.GetSettings();
WV = self.GetWaveforms();
WVD = WV.data;
[nSpikes, nCh, nSamp] = size(WVD);

F = figure('Name', ['Waveforms: ' self.name], ...
    'Tag', MCS.DeletableFigureTag, ...
    'Units','Normalized');

[x,y] = ndgrid(1:nSamp, 1:nCh);
xrange = x+nSamp*1.5*y;

ax = axes('Parent', F, 'Units','Normalized', ...
'Position', [0.15 0.15 0.7 0.7]);
slider_nSpikesToDisplay = ...
    uicontrol('Parent', F, ...
    'Units','Normalized', ...
    'Position', [0.15 0.05 0.7 0.05], ...
    'Style', 'slider', ...
    'min', 1, 'max', nSpikes, ...
    'value', min(1000, nSpikes), ...
    'Callback', @(src,event)RedrawWaveforms);

RedrawWaveforms();

% -------------------------------------
function RedrawWaveforms()
    nToPlot = floor(get(slider_nSpikesToDisplay, 'Value'));
    r = randperm(nSpikes, nToPlot);
    cla(ax); hold on
    for iCh = 1:nCh
        h = plot(ax, xrange(:,iCh), squeeze(WVD(r, iCh, :))); % nCh -> iCh ADR 2013-12-12
        if useSelfColor, set(h, 'color', self.color); end
    end
    set(gca, 'YLim', MCS.AverageWaveform_ylim, 'YTick', [0], 'XTick', []);
    title(sprintf('%d waveforms from %s', nToPlot, self.name));
end
end
function ClusterFunc_ShowHistAtPeak(self)

% ClusterFunc_ShowHistAtPeak(self)
% ADR 2003
%
% Status: PROMOTED (Release version)
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M4.0.
% Extensively modified by ADR to accomodate new ClusterOptions methodology

nBins = 20;

MCS = MClust.GetSettings();
Spikes = self.GetSpikes();

if isempty(Spikes)
    msgbox('No points in cluster.')
    return
else
    WV = self.GetWaveforms();
    WVD = WV.data();
    [nSpikes, nCh, nSamp] = size(WVD);
    mWV = squeeze(mean(WVD));
    [~, peak] = max(mWV,[],2);
    
    figure('Name', ['Hist@Peak plot: ' self.name], ...
        'Tag', MCS.DeletableFigureTag);
    plotsub = ceil(sqrt(nCh));
    for iCh = 1:nCh
        subplot(plotsub, plotsub, iCh);
        W0 = squeeze(WVD(:,iCh,peak(iCh)));
        [H,x] = hist(W0,nBins);
        bar(x,H);
    end
    
end

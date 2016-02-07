function ClusterFunc_ShowAverageWaveform(self)

% ShowWaveformDensity(self)
% ADR 2003
%
% Status: PROMOTED (Release version)
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M4.0.
% Extensively modified by ADR to accomodate new ClusterOptions methodology

MCS = MClust.GetSettings();
Spikes = self.GetSpikes();

if isempty(Spikes)
    msgbox('No points in cluster.')
    return
else
    WV = self.GetWaveforms();
    MClust.AverageWaveform(WV, ...
        'myTitle', ['Average Waveform: Cluster ' self.name], ...
        'myFigureTag', MCS.DeletableFigureTag);
end

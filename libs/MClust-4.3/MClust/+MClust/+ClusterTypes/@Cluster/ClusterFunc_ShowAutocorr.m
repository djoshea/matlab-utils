function ClusterFunc_ShowAutocorr(self)

% ClusterFunc_ShowAutocorr(self)
% ADR 2012
%
% Status: PROMOTED (Release version)
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M4.0.
% Extensively modified by ADR to accomodate new ClusterOptions methodology

MCS = MClust.GetSettings();

Spikes = self.GetSpikes();
T = self.GetSpikeTimes();

if isempty(Spikes)
    msgbox('No points in cluster.')
    return
else
	MClust.AutoCorr(T, ...
        'myTitle', ['Autocorr: Cluster ' self.name], ...
        'myFigureTag', MCS.DeletableFigureTag);
end

function ClusterFunc_ShowCrosscorr(self)

% ClusterFunc_ShowCrosscorr(self)
% ADR 2012
%
% Status: PROMOTED (Release version)
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M4.0.
% Extensively modified by ADR to accomodate new ClusterOptions methodology
%
% 2013-08-26 Updated to allow multiple cross-corrs to a given cluster

MCD = MClust.GetData();
MCS = MClust.GetSettings();
MCC = self.getAssociatedCutter();

names = MCC.getClusterNames();
clusterToCompare = listdlg(...
    'ListString', names, ...
    'Name', 'Select cluster', ...
    'PromptString', 'Select cluster to compare to...', ...
    'OKString', 'DONE', 'CancelString', 'Cancel', ...
    'InitialValue', []);

if ~isempty(clusterToCompare)
    nToCorr = length(clusterToCompare);
    T1 = MCD.FeatureTimestamps(self.GetSpikes);
    figure('NumberTitle', 'off', 'Name', sprintf('CrossCorr: %s x ...', self.name), 'Tag', MCS.DeletableFigureTag);
    
    for iC = 1:nToCorr
        ax = subplot(nToCorr,1,iC);
        T2 = MCD.FeatureTimestamps(MCC.Clusters{clusterToCompare(iC)}.GetSpikes());
        MClust.CrossCorr(T1, T2, ...
            'myTitle', ['Cluster ' self.name ' x ' 'Cluster ' MCC.Clusters{clusterToCompare(iC)}.name], ...
            'axesHandle', ax);
    end
end
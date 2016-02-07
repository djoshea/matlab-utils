function [L,IsoD, F, m] = CalculateLRatio_and_IsolationDistance( self )
% Calculate LRatio and Isolation Distance for speed

% ADR 2013/12

% construct components

% 1. FD for each element of ClusterSeparationFeatures

MCS = MClust.GetSettings();
[T, F] = MClust.CalculateFeatures(MCS.ClusterSeparationFeatures);

nSpikes = length(T);
nFeat = length(F);

FD = nan(nSpikes, nFeat);

for iF = 1:nFeat
    FD(:,iF) = F{iF}.GetData();
end

[L, m] = MClust.ClusterQuality.L_Ratio(FD, self.GetSpikes());
IsoD = MClust.ClusterQuality.IsolationDistance(FD, self.GetSpikes());

end


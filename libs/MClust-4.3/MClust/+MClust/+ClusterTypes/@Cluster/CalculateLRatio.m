function [L, F, m] = CalculateLRatio( self )
% Calculate LRatio

% ADR 2012/12

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

end


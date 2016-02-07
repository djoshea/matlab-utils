function IsoD = CalculateIsolationDistance( self )
% Calculate Isolation Distance

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
    
IsoD = MClust.ClusterQuality.IsolationDistance(FD, self.GetSpikes());

end


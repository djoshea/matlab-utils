function CopyHulls(self, C0)

% Copy Convex hulls from C0 to self.  Replace with current features using
% matched names.

MCD = MClust.GetData;

self.featuresX = {};
self.featuresY = {};
self.xg = {};
self.yg  = {};

nL = length(C0.featuresX);
featureNames = cellfun(@(F) F.name, MCD.Features, 'UniformOutput', false);

for iL = 1:nL
    fX = find(strcmp(C0.featuresX{iL}.name, featureNames),1);
    fY = find(strcmp(C0.featuresY{iL}.name, featureNames),1);
    if isempty(fX) || isempty(fY)
        error('MClust::ConvexHullsCluster', 'Feature pair <%s,%s> not found in new feature set.', C0.featuresX{iL}.name, C0.featuresY{iL}.name)
    end
    self.featuresX{iL} = MCD.Features{fX};
    self.xg{iL} = C0.xg{iL};
    self.featuresY{iL} = MCD.Features{fY};
    self.yg{iL} = C0.yg{iL};
end
    
        

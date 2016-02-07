function Projection3(self)

% Recalculate Projection (self)
% Projection plan 3
%
% Modified from Jadin Jackson's original code.


MCD = MClust.GetData();

nFeatures = length(self.Features);
% --------------------------
% Find points in n-dimensions

C1 = self.PrimaryCluster;
C2 = self.SecondaryCluster;

FD = nan(nFeatures, MCD.nSpikes());
for iF = 1:nFeatures
	FD(iF,:) = self.Features{iF}.GetData();
end

% --------------------------
% Calculate Mahalanobis distance based on covariance matrix of primary
% cluster and find the distance between them that maximizes center separation

% Mahalanobize by FD1
FD1 = FD(:,C1.GetSpikes());
COV1 = cov(FD1');
FD = COV1^(-0.5)*FD;

% Mahalanobize by FD2
% FD2 = FD(:,C2.GetSpikes());
% COV2 = cov(FD2');
% FD = COV2^(-0.5)*FD;

% Find top two maximal distances in these two spaces
FD1 = FD(:,C1.GetSpikes());
FD2 = FD(:,C2.GetSpikes());
mu1 = mean(FD1,2);
mu2 = mean(FD2,2);
v12 = mu2-mu1;
[~,ix] = sort(v12,'descend');

% Select it
FDx = FD(ix(1),:);
FDy = FD(ix(2),:);

% CREATE FEATURE
self.FeatureX = MClust.Feature('Projection x', FDx);
self.FeatureY = MClust.Feature('Projection x', FDy);
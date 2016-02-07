function Projection2(self)

% Recalculate Projection (self)
% Projection plan 2
%
% Modified from Jadin Jackson's original code.

MCD = MClust.GetData();

nFeatures = length(self.Features);

% --------------------------
% Find points in n-dimensions

C1 = self.PrimaryCluster;
C2 = self.SecondaryCluster;

FD = nan(MCD.nSpikes(), nFeatures);
for iF = 1:nFeatures
	FD(:,iF) = self.Features{iF}.GetData();
end
FD1 = FD(C1.GetSpikes(),:);
FD2 = FD(C2.GetSpikes(),:);

% --------------------------
% Calculate Mahalanobis distance based on covariance matrix of primary
% cluster and find the distance between them that maximizes center separation

% Find vector to define plane between cluster centers
mf1 = mean(FD1);
mf2 = mean(FD2);
V12x = (mf2 - mf1)';

%  Find principal axes and eigenvalues from first cluster
COV1 = cov(FD1);
[U1,S1,V1,converge_errorflag]=svds(COV1,length(COV1));

if converge_errorflag % did not converge
	warning('MClust:CutOnBestProjection', ...
		'Diagonalization not possible, use different feature space');
	self.FeatureX = self.Features{1};
	self.FeatureY = self.Features{2};
end


COV2 = cov(FD(C2.GetSpikes(),:));
[~,ix] = sort(abs(diag(COV2)));
Vbx = U1(:, ix(1));
Vby = U1(:, ix(2));

% Project it
FDx = FD*Vbx;
FDy = FD*Vby;

% CREATE FEATURE
self.FeatureX = MClust.Feature('Projection x', FDx);
self.FeatureY = MClust.Feature('Projection x', FDy);


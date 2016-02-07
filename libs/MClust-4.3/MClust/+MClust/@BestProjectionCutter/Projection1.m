function Projection1(self)

% Recalculate Projection (self)
% Projection plan 1
%
% Modified from Jadin Jackson's original code.

% Simplest projection path 1

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

% Find principal axes and eigenvalues from first cluster
COV1 = cov(FD1);
[U1,S1,V1,converge_errorflag]=svds(COV1,length(COV1));

if converge_errorflag % did not converge
	warning('MClust:CutOnBestProjection', ...
		'Diagonalization not possible, use different feature space');
	self.FeatureX = self.Features{1};
	self.FeatureY = self.Features{2};
end

% Transform clusters into a coordinate system where cluster 1 is unit
% gaussian centered at origin and covariance matrix of cluster 1 is diagonal (D1)
FD1_transformed=((FD1-repmat(mf1,C1.nSpikes(),1))*U1)/sqrt(S1);
FD2_transformed=((FD2-repmat(mf1,C2.nSpikes(),1))*U1)/sqrt(S1);

%  Find 3D that separate best
V12x_transformed=(U1/sqrt(S1))'*V12x; % transform vector 1->2
COV2 = cov(FD2_transformed); % covariance of cluster 2 in new coordinate system
V12d2 = COV2\(V12x.^2); % effective distance in each dimension from the cluster center
[ys, yi] = sort(abs(V12d2), 'descend');  % sort by center distance in transformed space

% --- Find best projection on that 3D
bestproj = yi(1:3);
COV2 = cov(FD(C2.GetSpikes(), bestproj));
[~,ix] = max(abs(diag(COV2)));
Vb0 = U1(bestproj, ix(1));
Vbx = V12x_transformed(bestproj);
Vby = cross(Vbx, Vb0);

% Project it
FDx = FD(:,bestproj)*Vbx;
FDy = FD(:,bestproj)*Vby;

% CREATE FEATURE
self.FeatureX = MClust.Feature('Projection x', FDx);
self.FeatureY = MClust.Feature('Projection x', FDy);
function SetParms(self, varargin)
%
% SetParms for convex hull cluster

self.SetParms@MClust.ClusterTypes.DisplayableCluster(varargin{:});
if isa(varargin{1}, 'MClust.ClusterTypes.CvxHullCluster')
    self.CopyHulls(varargin{1});
elseif isa(varargin{1}, 'MClust.ClusterTypes.Cluster')
	S = varargin{1}.GetSpikes();
	MCC = self.getAssociatedCutter();
	featuresToLimit = MCC.Features;
	% don't limit time
	timefeature = cellfun(@(x)streq(x.name, '_Time'), featuresToLimit);
	featuresToLimit(timefeature) = [];
	% create limits from convex hulls of selected spikes
	iL = 1;
	for iX = 1:length(featuresToLimit)
		FDx = featuresToLimit{iX}.GetData();
		for iY = (iX+1):length(featuresToLimit)
			FDy = featuresToLimit{iY}.GetData();
			self.featuresX{iL} = MCC.Features{iX};
			self.featuresY{iL} = MCC.Features{iY};
			[k] = convhull(FDx(S), FDy(S));
			self.xg{iL} = FDx(S(k));
			self.yg{iL} = FDy(S(k));
			iL = iL+1;
		end
	end
end
end

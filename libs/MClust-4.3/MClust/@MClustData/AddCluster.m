function C = AddCluster(self, ClusterType)

% MClustData
%
% Add cluster if room

if length(self.Clusters) < self.maxClusters
    C = feval(ClusterType);
    self.Clusters{end+1} = C;
else
    C = [];
    warning('MClust:TooManyClusters', ...
        'Tried to add clusters beyond maximum.\n Current maximum is %d.', self.maxClusters);
end
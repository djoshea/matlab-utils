function ApplyConvexHullsFromFile(self)

% ApplyConvexHullsFromFile
% Loads a set of convex hulls and appends new convex hull clusters if the
% feature names match

% Get settings
MCS = MClust.GetSettings();

% Get file name and load clusters
[fn,fd] = uigetfile(['*' MCS.defaultCLUSText], ...
    'Clusters File', ['*' MCS.defaultCLUSText]);
if ~isequal(fn, 0) % no file found
    load(fullfile(fd,fn), 'Clusters', '-mat');
else
    Clusters = {};
end

% Apply clusters
nC = length(Clusters);
for iC = 1:nC
    C0 = Clusters{iC};
    if ~isa(C0, 'MClust.ClusterTypes.CvxHullCluster')
        warning('MClust::ApplyCvxHulls', 'Cluster %d: %s is not a convex hull cluster.  Ignoring.', iC, C0.name);
    else
        C1 = MClust.ClusterTypes.CvxHullCluster();
        C1.SetParms(C0);  % includes copying hulls
        self.Clusters{end+1} = C1;
    end
end





end
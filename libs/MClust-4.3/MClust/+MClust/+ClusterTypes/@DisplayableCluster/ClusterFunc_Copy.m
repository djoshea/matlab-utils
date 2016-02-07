function ClusterFunc_Copy(self)

% f = CopyCluster(self)

% ncst 26 Nov 02
% ADR 2008
%

self.getAssociatedCutter().StoreUndo(['Copy' self.name]);
newCluster = self.MakeCopy();
newCluster.name = ['Copy of ' self.name];


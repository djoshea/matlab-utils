function ClusterFunc_02_DeleteCluster(self)

% f = DeleteCluster()
%
% ncst 26 Nov 02
% ADR 2008
%

MCC = self.getAssociatedCutter();
MCC.StoreUndo('Delete Cluster');
Iam = MCC.findSelf(self);
MCC.Clusters(Iam) = [];
MCC.ReGo();
function  ClusterFunc_SplitSpikesByPolygon(self)

% PreCut Clusters - ClusterFunction_SplitSpikesByConvexHull
%
% Adds ability to Creates a new cluster from those within the convex hull, leaves the rest

MCC = self.getAssociatedCutter();
MCC.StoreUndo('Limit Spikes by Convex hull');

[xg,yg] = DrawPolygonOnAxes(MCC, false);
plot(xg,yg,'-', 'color', self.color); 
drawnow;

% get axes
xFeat = MCC.get_xFeature();
yFeat = MCC.get_yFeature();

% get FD data
xFD = xFeat.GetData();
yFD = yFeat.GetData();

S = self.GetSpikes();
OK = inpolygon(xFD(S),yFD(S),xg,yg);

newCluster = self.MakeCopy();
newCluster.RenameCluster([self.name '-split']);
newCluster.ChangeColor(1-newCluster.color);
newCluster.SetSpikes(S(~OK));

self.SetSpikes(S(OK));
MCC.RedrawAxes();
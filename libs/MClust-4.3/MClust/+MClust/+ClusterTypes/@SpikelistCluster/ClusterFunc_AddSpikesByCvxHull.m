function  ClusterFunc_AddSpikesByCvxHull(self)

% PreCut Clusters - ClusterFunction_AddSpikesByConvexHull
%
% Adds ability to add individual spikes

MCC = self.getAssociatedCutter();
MCC.StoreUndo('Add Spikes by Cvx Hull');

[xg,yg] = DrawPolygonOnAxes(MCC, true);
plot(xg,yg,'-', 'color', self.color); 
drawnow;



% get axes
xFeat = MCC.get_xFeature();
yFeat = MCC.get_yFeature();

% get FD data
xFD = xFeat.GetData();
yFD = yFeat.GetData();

OK = inpolygon(xFD,yFD,xg,yg);
self.AddSpikes(find(OK));
MCC.RedrawAxes();
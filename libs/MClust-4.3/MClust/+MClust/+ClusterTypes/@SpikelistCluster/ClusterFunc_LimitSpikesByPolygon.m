function  ClusterFunc_LimitSpikesByPolygon(self)

% PreCut Clusters - ClusterFunction_LimitSpikesByConvexHull
%
% Adds ability to limit spikes

MCC = self.getAssociatedCutter();
MCC.StoreUndo('Limit Spikes by Polygon');

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
self.SetSpikes(S(OK));
MCC.RedrawAxes();
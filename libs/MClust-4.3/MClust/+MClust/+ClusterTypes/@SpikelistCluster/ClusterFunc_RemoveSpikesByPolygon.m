function ClusterFunc_RemoveSpikesByPolygon(self)

% PreCut Clusters - ClusterFunc_RemoveSpikesByPolygon
%
% Adds ability to add individual spikes

MCC = self.getAssociatedCutter();
[xg,yg] = DrawPolygonOnAxes(MCC, false);
plot(xg,yg,'-', 'color', self.color); 
drawnow;

MCC.StoreUndo('Add Spikes');

% get axes
xFeat = MCC.get_xFeature();
yFeat = MCC.get_yFeature();

% get FD data
xFD = xFeat.GetData();
yFD = yFeat.GetData();

S = self.GetSpikes();
OK = inpolygon(xFD(S),yFD(S),xg,yg);
self.RemoveSpikes(S(OK));
MCC.RedrawAxes();
function ClusterFunc_AddSpikesFromUnaccountedByPolygon(self)

% PreCut Clusters - ClusterFunc_RemoveSpikesByPolygon
%
% Adds ability to add individual spikes

MCC = self.getAssociatedCutter();
MCC.StoreUndo('Add Spikes from unaccounted by Polygon');

[xg,yg] = DrawPolygonOnAxes(MCC, false);
plot(xg,yg,'-', 'color', self.color); 
drawnow;


% get axes
xFeat = MCC.get_xFeature();
yFeat = MCC.get_yFeature();

% get FD data
xFD = xFeat.GetData();
yFD = yFeat.GetData();

S = MCC.getUnaccountedForPoints();
OK = inpolygon(xFD(S),yFD(S),xg,yg);
self.AddSpikes(S(OK));
MCC.RedrawAxes();
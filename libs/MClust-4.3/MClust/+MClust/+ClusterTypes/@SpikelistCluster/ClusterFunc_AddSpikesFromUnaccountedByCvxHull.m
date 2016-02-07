function ClusterFunc_AddSpikesFromUnaccountedByCvxHull(self)

% PreCut Clusters - ClusterFunc_RemoveSpikesByPolygon
%
% Adds ability to add individual spikes

MCC = self.getAssociatedCutter();
MCC.StoreUndo('Add Spikes from Unaccounted by Cvx Hull');

[xg,yg] = DrawPolygonOnAxes(MCC, true);
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
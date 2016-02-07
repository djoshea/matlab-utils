function ClusterFunc_AddSpikesByPolygon(self)

% PreCut Clusters - ClusterFunction_AddSpikesByPolygon
%
% Adds ability to add individual spikes

MCC = self.getAssociatedCutter();
MCC.StoreUndo('Add Spikes by Polygon');

[xg,yg] = DrawPolygonOnAxes(MCC, false);
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
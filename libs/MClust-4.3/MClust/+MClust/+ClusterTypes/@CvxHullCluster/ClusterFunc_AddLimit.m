function  ClusterFunc_AddLimit(self)

% Convex Hull clsuter add limit

MCC = self.getAssociatedCutter();
[xg,yg] = DrawPolygonOnAxes(MCC, true);
plot(xg,yg,'-', 'color', self.color); 
drawnow;

MCC.StoreUndo('Add Limit');

% get axes
xFeat = MCC.get_xFeature();
yFeat = MCC.get_yFeature();

iL = self.findLimit(xFeat, yFeat);
if ~isempty(iL)
    self.xg{iL} = xg;
    self.yg{iL} = yg;
else
    self.featuresX{end+1} = xFeat;
    self.featuresY{end+1} = yFeat;
    self.xg{end+1} = xg;
    self.yg{end+1} = yg;
end

MCC.RedrawAxes();
end
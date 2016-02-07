function  ClusterFunc_DeleteLimit(self)

% Convex Hull clsuter add limit

MCC = self.getAssociatedCutter();

MCC.StoreUndo('Delete Limit');

% get axes
xFeat = MCC.get_xFeature();
yFeat = MCC.get_yFeature();

iL = self.findLimit(xFeat, yFeat);
if ~isempty(iL)
    self.featuresX(iL) = [];
    self.featuresY(iL) = [];    
    self.xg(iL) = [];
    self.yg(iL) = [];
end

MCC.RedrawAxes();
end
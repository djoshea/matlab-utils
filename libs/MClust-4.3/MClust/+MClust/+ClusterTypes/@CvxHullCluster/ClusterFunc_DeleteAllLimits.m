function  ClusterFunc_DeleteAllLimits(self)

% Convex Hull clsuter add limit

MCC = self.getAssociatedCutter();

MCC.StoreUndo('Delete all limits');

self.featuresX = {};
self.featuresY = {};
self.xg = {};
self.yg = {};

MCC.RedrawAxes();
end

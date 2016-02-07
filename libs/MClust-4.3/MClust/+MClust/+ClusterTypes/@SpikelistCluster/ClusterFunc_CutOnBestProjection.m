function  ClusterFunc_CutOnBestProjection(self)

% PreCut Clusters - ClusterFunc_CutOnBestProjection
%
% Adds ability to cut differences between this cluster and all others by
% merging and limiting

MCC = self.getAssociatedCutter();

FeatureNames = cellfun(@(x)x.name, MCC.Features, 'UniformOutput', false);
[Selection, OK] = listdlg(...
	'ListString', FeatureNames, ...
	'SelectionMode', 'multiple', ...
	'InitialValue', 1:(length(FeatureNames)-1), ...
	'PromptString', 'Select features to use for calculating projections.');
if OK
	MCC.StoreUndo('Cut On Best Projection');
	B = MClust.BestProjectionCutter(MCC, MCC.findSelf(self), MCC.Features(Selection));
end

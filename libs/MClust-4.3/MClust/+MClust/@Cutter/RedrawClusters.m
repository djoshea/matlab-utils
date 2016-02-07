function RedrawClusters(self)
% Redraw clusters within panel

nClustersInPanel = 30;
uicHeight = 1/nClustersInPanel;

panel = self.clusterPanel;

% clear old display
if ~isempty(get(panel, 'children'))
    delete(get(panel, 'children'));
end

% clusters to show?
C = self.getClusters();

if length(C) < nClustersInPanel;
    startCluster = 0;
    endCluster = length(C);
else
    startCluster = floor(min(length(C), -get(self.uiScrollbar, 'Value')));
    endCluster = floor(min(length(C), startCluster+nClustersInPanel));
end
nToShow = endCluster - startCluster;

% show them
for iC = 1:nToShow
    panel0 = uipanel(panel, ...
        'units', 'Normalized', 'position', [0 1-(iC)*uicHeight 1 uicHeight]);
    C{iC+startCluster}.PanelSelf(panel0, iC+startCluster);    
end
end


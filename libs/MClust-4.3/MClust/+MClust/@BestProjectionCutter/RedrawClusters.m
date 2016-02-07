function RedrawClusters(self)
% Redraw clusters within panel

%-----------------------
% FROM @Cutter - need to hide and disable primary cluster

% Redraw clusters within panel

uicHeight = 0.05;
nClustersInPanel = floor(1/uicHeight);
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
	if ~isequal(C{iC+startCluster},self.PrimaryCluster)
		panel0 = uipanel(panel, ...
			'units', 'Normalized', 'position', [0 1-(iC)*uicHeight 1 uicHeight]);
		C{iC+startCluster}.PanelSelf(panel0, iC+startCluster);
		
		showhide = findobj('parent', panel0, 'Tag', 'HideSelf');
		set(showhide, 'Style', 'RadioButton');
		set(showhide, 'Callback', @(src,event)TakeFocus(self, C{iC+startCluster}));
		
	end
end

%-----------------------------

% redraw primary cluster
panel = self.primaryClusterPanel;

% clear old display
if ~isempty(get(panel, 'children'))
    delete(get(panel, 'children'));
end

% clusters to show?
if ~isempty(self.PrimaryCluster)
	self.PrimaryCluster.PanelSelf(panel, []);
	
	showhide = findobj('parent', panel, 'Tag', 'HideSelf');
	set(showhide, 'enable', 'off');

end
end


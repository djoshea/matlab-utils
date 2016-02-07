function RedrawAxes(self, ~, ~)

MCS = MClust.GetSettings();

% Something has changed in the control window, redraw as necessary...

if self.get_redrawStatus()
    	
    % window for display
    if isempty(self.CC_displayWindow) || ~ishandle(self.CC_displayWindow)
        % create new drawing figure
        self.CC_displayWindow = ...
            figure('Name', 'Cluster Cutting Window',...
            'NumberTitle', 'off', ...
            'Tag', 'CHDrawingAxisWindow', ...
			'Position',MCS.CHDrawingAxisWindow_Pos);
    else
        % figure already exists -- select it
        figure(self.CC_displayWindow);
    end
           
    % get FD data
    xFD = self.FeatureX.GetData();
    yFD = self.FeatureY.GetData();
    
    clf;
    ax = axes('Parent', self.CC_displayWindow, ...
        'XLim', [min(xFD) max(xFD)], 'YLim', [min(yFD) max(yFD)]);
    hold on;
    
    % go!
    AllClusters = self.getClusters();
    for iC = 1:length(AllClusters)        
        if ~AllClusters{iC}.hide
            AllClusters{iC}.PlotSelf(xFD, yFD, ax, self.FeatureX, self.FeatureY); 
        end
	end 
	
	self.PrimaryCluster.PlotSelf(xFD, yFD, ax, self.FeatureX, self.FeatureY);
    
    zoom on
end
end
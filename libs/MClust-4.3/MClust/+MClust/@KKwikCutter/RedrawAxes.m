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
        MCS.PlaceWindow(self.CC_displayWindow); % ADR 2013-12-12
    else
        % figure already exists -- select it
        figure(self.CC_displayWindow);
    end
        
    % get axes
    xFeat = self.Features{self.get_xAxis};
    yFeat = self.Features{self.get_yAxis};
    
    % get FD data
    xFD = xFeat.GetData();
    yFD = yFeat.GetData();
    
    clf;
    ax = axes('Parent', self.CC_displayWindow, ...
        'XLim', [min(xFD) max(xFD)], 'YLim', [min(yFD) max(yFD)]);
    hold on;
    
    % go!
    AllClusters = self.getClusters();
    for iC = 1:length(AllClusters)        
        if ~AllClusters{iC}.hide
            AllClusters{iC}.PlotSelf(xFD, yFD, ax, xFeat, yFeat); 
        end
	end 
	
	self.whoHasFocus.PlotSelf(xFD, yFD, ax, xFeat, yFeat);
    
    xlabel(xFeat.name,'interpreter','none');
    ylabel(yFeat.name,'interpreter','none');
    zoom on
end
end
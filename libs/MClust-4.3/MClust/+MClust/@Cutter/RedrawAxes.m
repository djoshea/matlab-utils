function RedrawAxes(self, ~, ~)

MCS = MClust.GetSettings();

% Something has changed in the control window, redraw as necessary...

if ~self.get_redrawStatus()
    
    % ADR 2013-12-12 if uncheck redraw axes note that will need to reset window
    if ~isempty(self.CC_displayWindow) && ishandle(self.CC_displayWindow)
        % there's a window
        ax = get(self.CC_displayWindow, 'CurrentAxes');
        xLabel = get(get(ax, 'xlabel'), 'string');
        if xLabel(1) ~= '@'
            xlabel(ax, ['@@@-' xLabel]);
        end
    end
    
else % DRAW IT
        
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
    
    
    % ADR 2013-12-12 check if axes have changed
    ax = gca;
    if streq(get(get(ax, 'xlabel'), 'string'), xFeat.name) && ...
            streq(get(get(ax, 'ylabel'), 'string'), yFeat.name)
        xLim = get(ax, 'XLim');
        yLim = get(ax, 'YLim');
    else
        xLim = [min(xFD)-eps max(xFD)+eps]; 
        yLim = [min(yFD)-eps max(yFD)+eps];
    end
    
    clf;
    ax = axes('Parent', self.CC_displayWindow, ...
        'XLim', xLim, 'YLim', yLim);
    hold on;
    
    % go!
    AllClusters = self.getClusters();
    for iC = 1:length(AllClusters)        
        if ~AllClusters{iC}.hide
            AllClusters{iC}.PlotSelf(xFD, yFD, ax, xFeat, yFeat); 
        end
    end 
    
    xlabel(xFeat.name,'interpreter','none');
    ylabel(yFeat.name,'interpreter','none');
    zoom on
    
end

end
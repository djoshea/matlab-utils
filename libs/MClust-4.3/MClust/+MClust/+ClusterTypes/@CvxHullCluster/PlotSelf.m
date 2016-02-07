function PlotSelf(self, xFD, yFD, ax ,xFeat, yFeat)
% Redraw cluster using xFD and yFD on a given axes

S = self.GetSpikes();
h = plot(ax, xFD(S), yFD(S), '.', ...
    'marker', self.marker, ...
    'markerSize', self.markerSize, ...
    'color', self.color);

% is x,y one of the limits
iL = self.findLimit(xFeat, yFeat);
if ~isempty(iL)
    plot(self.xg{iL}, self.yg{iL}, 'color', self.color, 'LineWidth', 2);
end
 
end


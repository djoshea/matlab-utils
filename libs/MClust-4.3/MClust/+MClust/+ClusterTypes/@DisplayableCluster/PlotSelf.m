function PlotSelf(self, xFD, yFD, ax, ~, ~)
% Redraw cluster using xFD and yFD on a given axes

S = self.GetSpikes();
h = plot(ax, xFD(S), yFD(S), '.', ...
    'marker', self.marker, ...
    'markerSize', self.markerSize, ...
    'color', self.color);
end


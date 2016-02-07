function RecalculateProjection(self)

% Recalculate Projection (self)
%
% Modified from Jadin Jackson's original code.

iPath = self.projectionPath.GetI();
%fprintf('Recalculating using projection path %d\n', iPath);

switch (iPath)
	case 1
		self.Projection1();
	case 2
		self.Projection2();
	case 3
		self.Projection3();
	otherwise
		error('MClust:CutOnBestProjection', 'Unknown projection path.');
end

self.RedrawAxes();

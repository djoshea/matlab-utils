function [xg,yg] = DrawPolygonOnAxes(self, returnConvexHull)

% [x,y] = DrawPolygonOnAxes(self, returnConvexHull)
% 
% INPUTS
%        returnConvexHull = t/f
%
% OUTPUTS
%     x,y pair for use in "inpolygon"
%   
% ADR 2012/12
% MClust 4.0

MCC = self.CC_figHandle;

if isempty(MCC)
	warning('MClust:Cutter', 'No axes to draw on.');
	return;
end
if ~self.get_redrawStatus()
    warning('MClust:Cutter', 'RedrawAxes is not checked.  Axes not aligned.');
    return
end

self.FocusOnAxes();

[xg,yg] = ginput();
xg = [xg;xg(1)]; 
yg = [yg;yg(1)];
if returnConvexHull
	k = convhull(xg,yg); 
	xg = xg(k); 
	yg = yg(k);
end
		

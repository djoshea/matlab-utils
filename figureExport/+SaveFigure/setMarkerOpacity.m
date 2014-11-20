function setMarkerOpacity(s, faceAlpha, edgeAlpha)
% stores information in UserData struct to cause saveFigure to render
% marker points as translucent when exporting to svg
if nargin < 3
    edgeAlpha = 1;
end

for i = 1:length(s)
    userdata = get(s(i),'UserData');
    userdata.svg.MarkerFaceAlpha = faceAlpha;
    userdata.svg.MarkerEdgeAlpha = edgeAlpha;
    set(s(i),'UserData', userdata);
end

end
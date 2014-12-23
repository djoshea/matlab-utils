function setLineOpacity(s, alpha)
% stores information in UserData struct to cause saveFigure to render
% lines as translucent when exporting to svg

for i = 1:length(s)
    userdata = get(s(i),'UserData');
    userdata.svg.LineAlpha = alpha;
    set(s(i),'UserData', userdata);
end

end
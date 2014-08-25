clf;
b = AutoAxisPlotting.BarPlot(gca);

showGroups = true;
nGroups = 4;
nBars = 5;
cmap = jet(nBars);
for g = 1:nGroups
    if showGroups
        b.startGroup(sprintf('Group %d', g));
    end
    
    for i = 1:nBars
        b.addBar(i*10 + g*3, 'label', sprintf('bar%d', i), ...
            'error', i*2, 'faceColor', cmap(i, :));
    end

    if showGroups
        b.endGroup();
    end
end

au = AutoAxis(gca);
au.axisMarginBottom = 3;

ylabel('Awesomeness (AU)')

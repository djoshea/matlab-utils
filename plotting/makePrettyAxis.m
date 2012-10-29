
function makePrettyAxis(varargin)
    axh = gca;
    xOnly = false;
    yOnly = false;
    lineThickness = 1;
    assignargs(varargin);

    if isappdata(axh, 'drawAxisOrigLims')
        return;
    end

    drawX = ~yOnly;
    drawY = ~xOnly;

    if drawX
        xTick = get(axh, 'XTick');
        xTickLabel = cellFromCharArray(get(axh, 'XTickLabel'));
        xLabel = get(get(axh, 'XLabel'), 'String');
    end

    if drawY
        yTick = get(axh, 'YTick');
        yTickLabel = cellFromCharArray(get(axh, 'YTickLabel'));
        yLabel = get(get(axh, 'YLabel'), 'String');
    end
    
    axis(axh, 'off');
    box(axh, 'off');

    if drawX
        drawAxis(xTick, 'axisOrientation', 'h', 'tickLabels', xTickLabel, 'axisLabel', xLabel, ...
            'lineThickness', lineThickness);
    end
    if drawY
        drawAxis(yTick, 'axisOrientation', 'v', 'tickLabels', yTickLabel, 'axisLabel', yLabel, ...
            'lineThickness', lineThickness);
    end
end

function c = cellFromCharArray(ca)

    c = cell(size(ca,1), 1);
    for i = 1:size(ca,1)
        c{i} = strtrim(ca(i,:));
    end

end

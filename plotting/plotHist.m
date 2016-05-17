function n = plotHist(vals, binEdges, varargin)
% n = plotHist(vals, binEdges, varargin)

color = [];
normalize = [];
cdf = [];
def.normalize = false;
def.cdf = false;
def.excludeZero = false;
def.drawLine = true;
def.lineWidth = 2;
def.color = 'k';
def.axh = [];
def.showMedian = false;
def.showPValue = false;
def.xUnits = '';
def.showPercentile = false;
def.arrowAt = [];
def.arrowColor = 'k';
def.arrowLabel = {};
def.lineAt = [];
def.axisThickness = 1;
def.lineColor = [];
def.prettyAxis = true;
def.xname = '';
def.yname = '';
def.fillColor = [];
def.fillAlpha = 1;
def.zeroLine = true;
def.setAxisLimits = true;
assignargs(def, varargin);

n = histc(vals, binEdges);

if cdf
    n = cumsum(n);
end

if normalize
    n = n / length(vals);
end

if excludeZero
    n(n==0) = NaN;
end

if isempty(axh)
    %clf;
    axh = gca;
end

[xPts yPts] = stairs(binEdges, n);
xPts = [xPts(1); xPts; xPts(end)];
yPts = [0; yPts; 0];

if zeroLine
    plot([xPts(1) xPts(end)], [0 0], '-', 'Color', 0.8*ones(3,1));
end

if ~isempty(fillColor)
    patch(xPts, yPts, fillColor, 'FaceAlpha', fillAlpha, 'EdgeColor', 'none');
    hold on
end

if drawLine
    stairs(xPts, yPts, '-', 'LineWidth', lineWidth, 'Color', color, 'Parent', axh);
end
hold on
    
box off

yl = [0 nanmax(n) * 1.2];
if isnan(yl(2)) || yl(2) <= 0
    yl(2) = 1;
end
arrowY = [yl(2) yl(2)*.8];

if setAxisLimits
    ylim(axh, yl);
    xlim(axh, minmax(binEdges));
end

if showMedian
    hold on
    yl = ylim(); 
    m = nanmedian(vals);

    if any(~isnan(vals)) && ~isempty(vals)
        p = signrank(vals);
    else
        p = NaN;
    end
    if p < 0.05
        color = 'r';
    else
        color = 'k';
    end
   
    if ~isnan(m)
        drawArrow([m m], arrowY, 'Color', color);
    end
    
    if isempty(xUnits)
        xUnitsStr = '';
    else
        xUnitsStr = [' (' xUnits ')'];
    end
    if showPValue
        pStr =  getPValueStr(p);
        if ~isempty(pStr)
            pStr = [', ' pStr];
        end
        text(m, yl(2), sprintf(' %.3g%s%s', m, xUnitsStr, pStr), 'VerticalA', 'top',...
            'HorizontalA', 'left', 'Color', color);
    else
        text(m, yl(2), sprintf(' %.3g%s', m, xUnitsStr), 'VerticalA', 'top',...
            'HorizontalA', 'left', 'Color', color);
    end
end

if showPercentile ~= false && ~isempty(removenan(vals))
    prcVal = prctile(removenan(vals), 100*showPercentile);
    plot([prcVal prcVal], yl, '--', 'Color', 0.6*ones(3,1));
end

for i = 1:length(lineAt) 
    if ~isempty(lineColor)
        if iscell(lineColor)
            color = lineColor{i};
        else
            color = lineColor;
        end
    else
        color = 0.6*ones(3,1);
    end
    plot([lineAt(i) lineAt(i)], yl, '--', 'Color', color);
end

if ~isempty(arrowAt)
    for i = 1:length(arrowAt)
        if iscell(arrowColor) && length(arrowColor) >= i
            color = arrowColor{i};
        else
            color = arrowColor;
        end
            
        drawArrow([arrowAt arrowAt], arrowY, 'color', color); 
        
        if ~isempty(arrowLabel)
            if iscell(arrowLabel)
                label = arrowLabel{i}; 
            elseif ischar(arrowLabel) 
                label = arrowLabel;
            end
            
            text(arrowAt, arrowY(1), [' ' label], 'VerticalA', 'top', 'HorizontalA', 'left', ...
                'Color', color);
        end
    end

end

if ~isempty(xname)
    xlabel(xname);
end
if ~isempty(yname)
    ylabel(yname);
end

if prettyAxis
    makePrettyAxis('lineThickness', axisThickness);
end

hold off

end

function s = getPValueStr(p)
    if p < 0.0001
        s = 'p < 0.0001';
    elseif p < 0.001
        s = 'p < 0.001';
    elseif p < 0.01
        s = 'p < 0.01';
    elseif p < 0.05 
        s = 'p < 0.05';
    else
        s = '';
    end
%         s = sprintf('p > 0.05 [%.3f]', p);
%     end
end

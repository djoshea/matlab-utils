function n = plotHist(vals, binEdges, varargin)
% n = plotHist(vals, binEdges, varargin)

color = [];
normalize = [];
cdf = [];
def.normalize = false;
def.cdf = false;
def.excludeZero = false;
def.lineWidth = 2;
def.color = 'k';
def.axh = [];
def.showMedian = false;
def.showPercentile = false;
def.arrowAt = [];
def.arrowColor = 'k';
def.arrowLabel = {};
def.lineAt = [];
def.axisThickness = 1;
def.lineColor = [];
def.prettyAxis = true;
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

stairs(binEdges, n, '-', 'LineWidth', lineWidth, 'Color', color, 'Parent', axh);
hold on
box off

yl = [0 nanmax(n) * 1.2];
if isnan(yl(2)) || yl(2) <= 0
    yl(2) = 1;
end
ylim(axh, yl);
arrowY = [yl(2) yl(2)*.8];
xlim(axh, minmax(binEdges));

if prettyAxis
    makePrettyAxis('lineThickness', axisThickness);
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
    
    text(m, yl(2), sprintf(' %.3g, p = %.3g', m, p), 'VerticalA', 'top',...
        'HorizontalA', 'left', 'Color', color);
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

hold off





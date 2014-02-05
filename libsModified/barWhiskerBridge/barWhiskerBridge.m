function barWhiskerBridge(inBar,inWhisker,bridgeInfo, sigBar, colors, barNames, clusterNames, yAxisLabel, varargin)
%BARWHISKERBRIDGE creates a clustered bar-and-whisker plot with signficance stars and bridges connecting related bars
%
% barWhiskerBridge(bars, whiskers, sigBridge, sigBar, colors, barNames, clusterNames, yAxisLabel, varargin)
% bars [nClusters, nBars] : bar heights
% whiskers [nClusters, nBars, 1 or 2] : whisker heights (separate below, above if
% 3rd dimension is size 2)
% bridgeInfo [K, 5] : each row [c1 b1 c2 b2 nStars] is a bridge from bar b1 in
%     cluster c1 to bar b2 in cluster c2 with nStars '*' drawn above
% sigBar [nClusters, nBars] : nStars to draw above each bar
% barNames {nClusters, nBars} : cellstr of bar labels
% clusterNames {nClusters} : cellstr of cluster labels
% yAxisLabel : string to label y axis with
% 
% optional params:
%  'showValues' : true/false : show numerical value above bar
%  'valuePrecision' : scalar : values will be shown with # decimal points
%
% Modified by dan@djoshea.com from
% http://www.mathworks.com/matlabcentral/fileexchange/36023-bar-plot-with-whiskers-and-significance-bridges
%

p = inputParser();
p.addParamValue('showValues', false, @islogical);
p.addParamValue('valuePrecision', 1, @isscalar);
p.parse(varargin{:});

showValues = p.Results.showValues;
valuePrecision = p.Results.valuePrecision;

if size(inWhisker, 3) == 1
    inWhisker = repmat(inWhisker, 1, 1, 2);
end
% height of whisker below
inWhiskerL = inWhisker(:, :, 1);
% height of whisker above
inWhiskerH = inWhisker(:, :, 2);

%aesthetics
%bridgeGap determines the minimum distance from the end of the whiskers to
%the start of the bridges
maxVal = max(inBar(:)+inWhiskerH(:));
minVal = min(inBar(:)-inWhiskerL(:));
scale= maxVal - minVal;
bridgeGap = 0.02*scale;
%bridgeStep determines the distance between one bridge connector and the
%next above it
bridgeStep = 0.03*scale;
%this value determines the additional step allocated for bridges which have
%additional markers
starGap = 0.01*scale;
barNameGap = 0.03*scale;
clusterNameGap = 0.06*max(inBar(:)+inWhiskerH(:)) + barNameGap;

nClusters = size(inBar,1);
nBarsInCluster = size(inBar,2);

%number of possible bridges
bee = nBarsInCluster*(nBarsInCluster-1)/2;

baseline = 0;

%width of bars
Xwidth = 0.9;
%distance between bars
XGapBar = 0.2;
XGapCluster = 0.2;
%set the offset for the first bar
Xoffset = 0;

%this keeps track of how high the plot ever gets
maxY = 0;
YbotMin = 0;
Xticks = [];

clusterStart = nan(nClusters, 1);
clusterMiddles = nan(nClusters, 1);
clusterStop = nan(nClusters, 1);
barX = nan(nClusters, nBarsInCluster);
barMaxY = nan(nClusters, nBarsInCluster);
barMinY = nan(nClusters, nBarsInCluster);

%% Plot the bars, whiskers, and bar significance stars

for iC = 1:nClusters
    Xmiddles = NaN(nBarsInCluster,1);
    YwhiskersL = NaN(nBarsInCluster,1);
    YwhiskersH = NaN(nBarsInCluster,1);
    
    clusterStart(iC) = Xoffset;
    
    %first make the bars
    for iB = 1:nBarsInCluster
        if ~isnan(inBar(iC,iB)) && ~isnan(inWhiskerH(iC,iB))
            XmiddleNow = Xoffset + Xwidth/2 + XGapBar;
            
            barX(iC, iB) = XmiddleNow;
            Xticks = [Xticks, XmiddleNow];
            Ybar = inBar(iC,iB);
            
            whiskLenH = inWhiskerH(iC, iB);
            whiskLenL = inWhiskerL(iC, iB);
            if(Ybar < 0)
                y0 = Ybar;
                yH = -Ybar;
                yText = Ybar - whiskLenL - starGap;
                YwhiskersL(iB) = Ybar - whiskLenL;
                YwhiskersH(iB) = Ybar + whiskLenH;
                barMinY(iC, iB) = Ybar - whiskLenL;
                barMaxY(iC, iB) = max(0, Ybar + whiskLen);
            else
                y0 = 0;
                yH = Ybar;
                yText = Ybar + whiskLenH + starGap;
                YwhiskersH(iB) = Ybar + whiskLenH;
                YwhiskersL(iB) = Ybar - whiskLenL;
                barMinY(iC, iB) = min(0, Ybar - whiskLenL);
                barMaxY(iC, iB) = Ybar + whiskLenH;
            end
            
            rectangle('position',[ (XmiddleNow-Xwidth/2) , y0 , Xwidth , yH ],...
                'edgecolor','none','facecolor', colors{iC, iB});
            hold on
            if whiskLenL + whiskLenH > 0
                h = rectangle('position', [XmiddleNow-Xwidth/20, Ybar-whiskLenL, Xwidth / 10, whiskLenL+whiskLenH] ,...
                    'facecolor','k', 'edgecolor', 'none');
                hasbehavior(h, 'legend', false);
            end
           
            if showValues
                h = text(XmiddleNow, yText, sprintf('%.*f', valuePrecision, Ybar), ...
                    'HorizontalAlign', 'Center', 'VerticalAlign', 'Bottom',  'Color', 'k', 'FontSize', 14);
                extent = get(h, 'Extent');
                yText = yText + extent(4);
            end
            
            % add the significance stars to each bar
            if sigBar(iC, iB) > 0
                h = text(XmiddleNow, yText, repmat('*', 1, sigBar(iC, iB)), ...
                    'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Middle', 'Color', 'k', 'FontSize', 14);
                
                extent = get(h, 'Extent');
                
                barMinY(iC, iB) = min(extent(2), barMinY(iC, iB));
                barMaxY(iC, iB) = max(extent(2)+extent(4), barMaxY(iC, iB));
            end
            
        end
        
        Xmiddles(iB) = XmiddleNow;
        Xoffset = Xoffset + XGapBar + Xwidth;
    end
    
    Xoffset = Xoffset + XGapBar;
    clusterMiddles(iC) = mean(Xmiddles);
    clusterStop(iC) = Xoffset;
    
    YwhiskersH = YwhiskersH + bridgeGap;
    Ytops = Ywhiskers;

    % advance a cluster
    Xoffset = Xoffset + XGapCluster;
    
    hold on
    
    % draw the baseline for this cluster
    h = line([clusterStart(iC) clusterStop(iC)], [baseline, baseline], 'LineStyle', '-', 'Color','k');
    hasbehavior(h, 'legend', false);
end

%now fill in the bridges
nBridges = size(bridgeInfo, 1);
assert(isempty(bridgeInfo) || size(bridgeInfo, 2) == 5, 'BridgeInfo must be K x 5');

minY = min(barMinY(:));
maxY = max(barMaxY(:));

trBarMaxY = barMaxY';

for iBridge = 1:nBridges
    row = bridgeInfo(iBridge, :);
    iC1 = row(1);
    iB1 = row(2);
    iC2 = row(3);
    iB2 = row(4);
    nStars = row(5);
    
    if nStars == 0
        continue;
    end
    
    % find height for bridge which clears all bars in between

    ind1 = sub2ind(size(trBarMaxY), iB1, iC1);
    ind2 = sub2ind(size(trBarMaxY), iB2, iC2);
    Ytop = max(trBarMaxY(ind1:ind2)) + bridgeStep + bridgeGap;
    trBarMaxY(ind1:ind2) = Ytop;
    
    Xl = barX(iC1, iB1);
    Xr = barX(iC2, iB2);
                    
    %now draw the bridge
    h = line( [Xl ; Xr] , Ytop*ones(2,1) ,'color','k','linewidth',1.5);
    hasbehavior(h, 'legend', false);
    h = line( Xl*ones(2,1) , [Ytop-bridgeGap;Ytop] ,'color','k','linewidth',1.5);
    hasbehavior(h, 'legend', false);
    h = line( Xr*ones(2,1) , [Ytop-bridgeGap;Ytop] ,'color','k','linewidth',1.5);
    hasbehavior(h, 'legend', false);

    %now add to the Ywhiskers to prevent bridge overlaps
    maxY = max(maxY, Ytop);

    h = text((Xl+Xr)/2,(Ytop + starGap),repmat('*', 1, nStars), ...
        'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Middle', 'Color', 'k', 'FontSize', 14);
        %add to the new top for the relevant bars
    extent = get(h, 'Extent');
    trBarMaxY(ind1:ind2) = extent(2) + extent(4);
    maxY = max(maxY, extent(2) + extent(4));
end
    
xlim([clusterStart(1), clusterStop(end)]);

if exist('yLims', 'var')
    ylim(yLims);
else
    ylim([minY maxY])
end

ylabel(yAxisLabel);
makePrettyAxis('yOnly', true);
figSetFonts('FontSize', 14);

for iC = 1:nClusters
    for iB = 1:nBarsInCluster
        text(barX(iC, iB), YbotMin - barNameGap, barNames{iC, iB}, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'Top', 'FontSize', 14);
    end
end

for iC = 1:nClusters
    text(clusterMiddles(iC), YbotMin - clusterNameGap, clusterNames{iC}, ...
        'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top', 'FontSize', 16);
end


outHandle = gca;






function outHandle = barWhiskerBridge(inBar,inWhisker,bridgeInfo, sigBar, colors, barNames, clusterNames, yAxisLabel, varargin)
%BARWHISKERBRIDGE creates a bar-and-whisker plot with bridges connecting
%related bars
%    OUTHANDLE = BARWHISKERBRIDGE( INBAR , INWHISKER , INBRIDGE ) outputs
%    the handle to an 'axes' containing a bar-and-whisker plot based on the
%    information in INBAR and INWHISKER; the plot is made in the currently
%    active axes.  INBAR and INWHISKER are N-by-M, where N is the number of
%    'clusters' and M is the number of bars within each 'cluster'.
%    INWHISKER determines how long the whiskers extend beyond the top of
%    the bars. If an element of either is NaN, the corresponding bar will not be made
%    INBRIDGE is an K x 5 array which contains
%    information on whether there is a significant relation between pairs
%    of bars. each row looks like:
%       [cluster1 bar1 cluster2 bar2 nStars]
%

if ~exist('inWhisker', 'var') || isempty(inWhisker)
    inWhisker = 0*inBar;
end

p = inputParser;
p.addParamValue('showValues', false, @islogical);
p.addParamValue('valuePrecision', 1, @isscalar);
p.parse(varargin{:});

showValues = p.Results.showValues;
valuePrecision = p.Results.valuePrecision;

%aesthetics
%bridgeGap determines the minimum distance from the end of the whiskers to
%the start of the bridges
maxVal = max(inBar(:)+inWhisker(:));
minVal = min(inBar(:)-inWhisker(:));
scale= maxVal - minVal;
bridgeGap = 0.02*scale;
%bridgeStep determines the distance between one bridge connector and the
%next above it
bridgeStep = 0.03*scale;
%this value determines the additional step allocated for bridges which have
%additional markers
starGap = 0.01*scale;
barNameGap = 0.03*scale;
clusterNameGap = 0.06*max(inBar(:)+inWhisker(:)) + barNameGap;

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
    Ywhiskers = NaN(nBarsInCluster,1);
    
    clusterStart(iC) = Xoffset;
    
    %first make the bars
    for iB = 1:nBarsInCluster
        if ~isnan(inBar(iC,iB)) && ~isnan(inWhisker(iC,iB))
            XmiddleNow = Xoffset + Xwidth/2 + XGapBar;
            
            barX(iC, iB) = XmiddleNow;
            Xticks = [Xticks, XmiddleNow];
            Ybar = inBar(iC,iB);
            
            whiskLen = inWhisker(iC, iB);
            if(Ybar < 0)
                y0 = Ybar;
                yH = -Ybar;
                yText = Ybar - whiskLen - starGap;
                Ywhiskers(iB) = Ybar - whiskLen;
                barMinY(iC, iB) = Ybar - whiskLen;
                barMaxY(iC, iB) = max(0, Ybar + whiskLen);
            else
                y0 = 0;
                yH = Ybar;
                yText = Ybar + whiskLen + starGap;
                Ywhiskers(iB) = Ybar + whiskLen;
                barMinY(iC, iB) = min(0, Ybar - whiskLen);
                barMaxY(iC, iB) = Ybar + whiskLen;
            end
            
            rectangle('position',[ (XmiddleNow-Xwidth/2) , y0 , Xwidth , yH ],...
                'edgecolor','none','facecolor', colors{iC, iB});
            hold on
            if whiskLen > 0
                h = rectangle('position', [XmiddleNow-Xwidth/20, Ybar-whiskLen, Xwidth / 10, 2*whiskLen] ,...
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
    
    Ywhiskers = Ywhiskers + bridgeGap;
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
        'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Middle', 'Color', 'k', 'FontSize', 14)
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






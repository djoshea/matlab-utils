function h = draw_violin(location, values, args)
    arguments
        location (1, 1) {mustBeNumeric}
        values (:, 1) {mustBeVector}
        args.evalPoints = []; % plot ks density at points
        args.width = 1
        args.bandwidth = []
        args.Parent = [];
        args.support = 'unbounded';
        args.style = 'ksdensity';
        
        args.FaceColor = [0 0.4470 0.7410];
        args.EdgeColor = 'none';
        
        args.binEdges = [];
        args.binWidth = [];
    end
    
    style = string(args.style);
    if isempty(args.Parent)
        parentArgs = {};
    else
        parentArgs = {'Parent', args.Parent};
    end
    
    switch style
        case 'ksdensity'
            if isempty(args.evalPoints)
                [f, xi]=ksdensity(values, 'bandwidth', args.bandwidth, 'support', args.support);
            else
                [f, xi] = ksdensity(values, args.evalPoints, 'bandwidth', args.bandwidth, 'support', args.support);
            end
            f = f';
            xi = xi';

            f=f/max(f)*args.width/2; %normalize
            XX = [f+location; flipud(location-f)];
            YY = [xi; flipud(xi)];
                
        case 'histogram'
            if isempty(b.binEdges)
                if isempty(b.binWidth)
                    [f, edges] = histcounts(Y);
                else
                    [f, edges] = histcounts(Y, 'BinWidth', b.binWidth);
                end
            else
                [f, edges] = histcounts(Y, b.binEdges);
            end

            f = f';
            edges = edges';
            f=f/max(f)*b.Width/2; %normalize

            % strip 0s from above and below so that the histograms only
            % extend as far as the distribution's support
            idx1 = find(f > 0, 1, 'first');
            if idx1 > 0
                f = f(idx1:end);
                edges = edges(idx1:end);
            end
            nTrail = numel(f) - find(f > 0, 1, 'last');
            if nTrail > 0
                f = f(1:end-nTrail);
                edges = edges(1:end-nTrail);
            end

            if ~isempty(f)
                if b.useStairs
                    [yo, xo] = stairs(edges, [f; f(end)]);
                    XX = [xo+xCenter; flipud(xCenter-xo)];
                    YY = [yo; flipud(yo)];
                else
                    xi = mean([edges(1:end-1) edges(2:end)], 2);
                    XX = [f+xCenter; flipud(xCenter-f)];
                    YY = [xi; flipud(xi)];
                end
            end
    end
    
    h = fill(XX, YY, args.FaceColor, parentArgs{:});
    if ~isempty(args.EdgeColor)
        h.EdgeColor = args.EdgeColor;
    end
end
function [weightedCounts, edges, bin] = histcountsWeighted(x, w, varargin)
    p = inputParser();
    p.KeepUnmatched = true;
    p.parse(varargin{:});
    
    x = x(:);
    w = w(:);
    [argsCounts, argsRem] = keepfields(p.Unmatched, {'BinEdges', 'BinLimits', 'BinMethod', 'BinWidth'});
    argsCounts = struct2paramValueCell(argsCounts);
    [~, edges, bin] = histcounts(x, argsCounts{:});
    nBins = numel(edges);
    
    mask = ~isnan(x) & ~isnan(w) & bin ~= 0;
    weightedCounts = accumarray(bin(mask), w(mask), [nBins, 1]);
end
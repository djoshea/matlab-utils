function axesSameLimits(h, mode, link)
% similar to linkaxes, except chooses limits to be the widest of the
% component axes. link = true means call linkaxes to keep them the same

    if nargin < 2
        mode = 'xy';
    end
    if nargin < 3
        link = true;
    end
    
    doX = ismember(mode, {'x', 'xy'});
    doY = ismember(mode, {'y', 'xy'});
        
    [xlByAxis, ylByAxis] = deal(nan(numel(h), 2));
    
    for i = 1:numel(h)
        xlByAxis(i, :) = get(gca, 'XLim');
        ylByAxis(i, :) = get(gca, 'YLim');
    end
    
    xl = [min(xlByAxis(:, 1)) max(xlByAxis(:, 2))];
    yl = [min(ylByAxis(:, 1)) max(ylByAxis(:, 2))];
    
    if doX
        set(h, 'XLim', xl);
    end
    if doY
        set(h, 'YLim', yl);
    end
    
    if ~link
        mode = 'off';
    end
    linkaxes(h, mode);
end
    
        
    

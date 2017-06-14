function equalizeAxisLimits(hax, which)

if nargin < 2
    which = 'xy';
end
doX = ismember('x', which);
doY = ismember('y', which);
doZ = ismember('z', which);

argsX = {};
argsY = {};
argsZ = {};

if doX
    xl = cell2mat(get(hax, 'XLim'));
    xl = [min(xl(:, 1)) max(xl(:, 2))];
    argsX = {'XLim', xl};
end

if doY
    yl = cell2mat(get(hax, 'YLim'));
    yl = [min(yl(:, 1)) max(yl(:, 2))];
    argsY = {'YLim', yl};
end

if doZ
    zl = cell2mat(get(hax, 'ZLim'));
    zl = [min(zl(:, 1)) max(zl(:, 2))];
    argsZ = {'ZLim', zl};
end

set(hax, argsX{:}, argsY{:}, argsZ{:});


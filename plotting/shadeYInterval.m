function [ha] = shadeYInterval(x, y1, y2, varargin)
% [ha] = shadeYInterval(x, y1, y2, varargin)
% shadeYInterval draws two lines on a plot and shades the area between those
% lines. ParamValues are same as for fill command (e.g. FaceColor,
% EdgeColor)
%

    % plot the shaded area
    x = makerow(x);
    y1 = makerow(y1);
    y2 = makerow(y2);

    if all(isnan(y1) | isnan(y2))
        ha = NaN;
        return;
    end

    isFirstRegion = true;

    % need to split the vecs
    nanMask = isnan(y1) | isnan(y2);
    offset = 1;
    while(offset < numel(x))
        % find next non-nan sample
        newOffset = find(~nanMask(offset:end), 1, 'first');
        if isempty(newOffset)
            break;
        end
        
        offset = offset+newOffset-1;
        nextNaN = find(nanMask(offset:end), 1, 'first');
        if isempty(nextNaN)
            regionEnd = numel(x);
        else
            regionEnd = nextNaN+offset - 2;
        end
        
        regionStart = offset;
        mask = regionStart:regionEnd;
        
        [ha] = shadeSimple(x(mask), y1(mask), y2(mask), varargin{:});
       
        offset = regionEnd + 1;
    end


end

function [ha] = shadeSimple(x, y1, y2, varargin)

p = inputParser();
p.addParamValue('FaceColor', [0.8 0.8 1], @(x) true);
p.addParamValue('EdgeColor', 'none', @(x) true);
p.KeepUnmatched = true;
p.parse(varargin{:});

ha = fill([x, fliplr(x)], [y1, fliplr(y2)], p.Results.FaceColor, ...
    'EdgeColor', p.Results.EdgeColor, ...
    p.Unmatched);

set(gca, 'Layer', 'top')

end

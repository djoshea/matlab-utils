function sz = figSizeScale(newSize, figh, varargin)
% figsize([width height], figh)
% figsize([width height]) - uses gcf by default
% 
% Sizes figure to height x width in cm

    scale = getFigureSizeScale();
    if nargin > 0
        sz = figSize(newSize * scale);
        sz = sz ./ scale;
    else
        sz = figSize();
        sz = sz ./ scale;
    end

end


function sz = figSizeScale(newSize, figh, varargin)
% figsize([width height], figh)
% figsize([width height]) - uses gcf by default
% 
% Sizes figure to height x width in cm

    scale = getFigureSizeScale();
    figSize(newSize * scale);

end


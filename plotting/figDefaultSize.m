function sz = figDefaultSize(defSize)
% figsize([width height]

    dpi = get(groot, 'ScreenPixelsPerInch');
    pos = get(groot, 'DefaultFigurePosition');
    pos(3:4) = defSize .* dpi / 2.54;

    set(groot, 'DefaultFigurePosition', pos);

end
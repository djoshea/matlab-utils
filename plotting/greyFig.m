function greyFig(figh)

    if nargin < 1
        figh = gcf;
    end
    figh.Color = [0.92 0.92 0.95];
    
    axh = findall(figh,'type','axes');
    set(axh, 'Color', 'none');
    

end


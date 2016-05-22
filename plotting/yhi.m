function yhi(v)
    yl = get(gca, 'YLim');
    del = yl(2) - yl(1);
    yl(2) = v;
    if yl(1) > v
        yl(1) = v - del;
    end
    set(gca, 'YLim', yl);
end
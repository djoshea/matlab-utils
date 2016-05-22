function ylo(v)
    yl = get(gca, 'YLim');
    del = yl(2) - yl(1);
    yl(1) = v;
    if yl(2) < v
        yl(2) = v + del;
    end
    set(gca, 'YLim', yl);
end
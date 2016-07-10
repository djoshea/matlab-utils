function xlo(v)
    xl = get(gca, 'XLim');
    del = xl(2) - xl(1);
    xl(1) = v;
    if xl(2) < v
        xl(2) = v + del;
    end
    set(gca, 'XLim', xl);
end
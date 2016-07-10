function xhi(v)
    xl = get(gca, 'XLim');
    del = xl(2) - xl(1);
    xl(2) = v;
    if xl(1) > v
        xl(1) = v - del;
    end
    set(gca, 'XLim', xl);
end
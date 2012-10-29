function tf = inRange(vals, range)
    if isscalar(range)
        range = [range range];
    end
    tf = vals >= range(1) & vals <= range(2);
end

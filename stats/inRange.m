function tf = inRange(vals, range)
    if isscalar(range)
        range = [range range];
    end
    if length(range) > 2
        error('Provide range as second argument');
    end
    tf = vals >= range(1) & vals <= range(2);
end

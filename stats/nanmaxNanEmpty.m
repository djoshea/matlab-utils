function r = nanmaxNanEmpty(v1)
    if isempty(v1)
        r = NaN;
    else
        r = nanmax(v1);
    end
end
function r = nanmaxNanEmpty(v)
    if ~isempty(v)
        r = nanmean(v);
    else
        r = NaN; 
    end
end
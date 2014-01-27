function r = nanmaxNanEmpty(v)
    if ~isempty(v)
        r = max(v);
    else
        r = NaN; 
    end
end
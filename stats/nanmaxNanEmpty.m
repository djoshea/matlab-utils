function r = nanmaxNanEmpty(v)
    if ~isempty(v)
        r = nanmax(v);
    else
        r = NaN; 
    end
end
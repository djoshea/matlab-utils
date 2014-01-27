function r = nanminNanEmpty(v)
    if ~isempty(v)
        r = min(v);
    else
        r = NaN; 
    end
end
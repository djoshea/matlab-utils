function r = nanminNanEmpty(v)
    if ~isempty(v)
        r = nanmin(v);
    else
        r = NaN; 
    end
end
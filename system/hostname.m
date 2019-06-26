function h = hostname()
    if nargout == 1
        [~, h] = unix('hostname');
        h = strtrim(h);
    else
        unix('hostname');
    end
end

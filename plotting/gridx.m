function gridx(mode)
    if nargin < 1
        mode = 'on';
    end
    set(gca, 'XGrid', mode);
end
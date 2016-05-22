function gridy(mode)
    if nargin < 1
        mode = 'on';
    end
    set(gca, 'YGrid', mode);
end
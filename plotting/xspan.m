function xspan(target, vec)
    if nargin < 2
        vec = target;
        target= gca;
    end
    xlim(target, [min(vec, [], 'all', 'omitmissing'), max(vec, [], 'all', 'omitmissing')]);
end
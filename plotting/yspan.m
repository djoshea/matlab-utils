function yspan(target, vec)
    if nargin < 2
        vec = target;
        target= gca;
    end
    ylim(target, [min(vec, [], 'all', 'omitmissing'), max(vec, [], 'all', 'omitmissing')]);
end
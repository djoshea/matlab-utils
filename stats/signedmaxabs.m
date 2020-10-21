function [val, ind] = signedmaxabs(x, dim)
% returns the max(abs(x), [], dim), but with the sign of x there

if nargout == 2
    [min_val, min_ind] = min(x, [], dim);
    [max_val, max_ind] = max(x, [], dim);

    val = min_val;
    ind = min_ind;

    mask = max_val > -min_val;
    val(mask) = max_val(mask);
    ind(mask) = max_ind(mask);
else
    % ind not supported for vecdim args
    min_val = min(x, [], dim);
    max_val = max(x, [], dim);

    val = min_val;
    mask = max_val > -min_val;
    val(mask) = max_val(mask);
end

end

function tf = isboolean(x)
    tf = isscalar(x) && islogical(x);
end
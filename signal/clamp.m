function val = clamp(val, lo, hi)
    val(val < lo) = lo;
    val(val > hi) = hi;
end
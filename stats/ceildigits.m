function B = ceildigits(A, digits)
    B = ceil(A * 10^digits) / 10^digits;
end
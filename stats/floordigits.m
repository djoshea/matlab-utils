function B = floordigits(A, digits)
    B = floor(A * 10^digits) / 10^digits;
end
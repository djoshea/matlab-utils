function mask = lower_mask_for_lower_real(T)

N = size(T, 1);
mask = tril(true(N, N)) & ~ diag_mask_for_lower_real(T);

end
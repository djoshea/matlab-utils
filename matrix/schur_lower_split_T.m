function [D, L] = schur_lower_split_T(T)

[D, L] = deal(zeros(size(T), 'like', T));

mask_diag = diag_mask_for_lower_real(T);
D(mask_diag) = T(mask_diag);
L(~mask_diag) = T(~mask_diag);

end
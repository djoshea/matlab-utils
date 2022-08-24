function p = calc_p_resample_vs_resample(resample1, resample2, tail)
    % this is a two-sided test (2* below) but we only check one side of the distribution.
    if strcmp(tail, "right")
        p = 1 - nnz(resample1(:) < resample2(:)') / (numel(resample1) * numel(resample2));
    else
        p = 1 - nnz(resample1(:) > resample2(:)') / (numel(resample1) * numel(resample2));
    end
    p = min(1, 2*p);
end
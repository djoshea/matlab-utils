function rsq = coeffdet(y_pred, y_true, mean_dims)

    SSR = sum((y_pred - y_true).^2, "all", "omitmissing");
    TSS = sum((y_true - mean(y_true, mean_dims, "omitmissing")).^2,  "all", "omitmissing");
    rsq = 1 - SSR / TSS;

end

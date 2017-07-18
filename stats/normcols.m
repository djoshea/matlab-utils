function W = normcols(W)

    W = W ./ sqrt(sum(W.^2, 1));

end
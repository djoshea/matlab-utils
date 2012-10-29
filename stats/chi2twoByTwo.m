function p = chi2twoByTwo(x1, x2, y1, y2)
% p = chi2twoByTwo(x1, x2, y1, y2)

chi2 = (x1 * y2 - x2 * y1) ^ 2 * (x1 +x2+y1+y2) / ((x1+y1) * (x2+y2) * (x1+x2) * (y1+y2));
p = 1 - chi2cdf(chi2, 1);

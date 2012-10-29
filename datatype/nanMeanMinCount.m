function m = nanmeanMinCount(x,dim,minCount)
%NANMEAN Mean value, ignoring NaNs and marking as Nan when the number of values is below
% minCount

if nargin == 2
    minCount = 1;
end

nans = isnan(x);
x(nans) = 0;

if nargin == 1 || isempty(dim) % let sum deal with figuring out which dimension to use
    % Count up non-NaNs.
    n = sum(~nans);
    tooFew = n < minCount;
    n(n==0) = NaN; % prevent divideByZero warnings
    % Sum up non-NaNs, and divide by the number of non-NaNs.
    m = sum(x) ./ n;
    m(tooFew) = NaN;
else
    % Count up non-NaNs.
    n = sum(~nans,dim);
    tooFew = n < minCount;
    n(n==0) = NaN; % prevent divideByZero warnings
    % Sum up non-NaNs, and divide by the number of non-NaNs.
    m = sum(x,dim) ./ n;
    m(tooFew) = NaN;
end


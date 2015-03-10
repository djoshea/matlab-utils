function [y, i] = nansortVector(x, mode)
% like sort, but puts nan values at the end, always

assert(isvector(x) && isnumeric(x), 'Only supports vector args');

if nargin < 2
    mode = 'ascend';
end

wasRow = isrow(x);

x = makecol(x);
[y, i] = sort(x, mode);

% move nans to the end
yisnan = isnan(y);
y = [y(~yisnan); y(yisnan)];
i = [i(~yisnan); i(yisnan)];

if wasRow
    y = y';
    i = i';
end

end
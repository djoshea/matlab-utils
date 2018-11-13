function n = meansq(m, dim)
% mean squared value
    if nargin < 2
        n = nanmean(m(:).^2);
    else
        n = nanmean(m.^2, dim);
    end
end
function map = hslmap(n, sat, lum)
% map = hslmap(n, sat, lum)

    if nargin < 2
        sat = 0.7;
    end
    if nargin < 3
        lum = 0.65;
    end

    hsl = [circspace(0, 360, n)', sat*ones(n, 1), lum*ones(n,1)];
    map = colorspace('HSL->RGB', hsl);

end

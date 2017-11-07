function cordiso(N)
% set color order to default

    if nargin < 1
        N = 6;
    end
    cord = pmkmp(N);
    set(groot, 'DefaultAxesColorOrder', cord);
    set(gca, 'ColorOrder', cord);

end
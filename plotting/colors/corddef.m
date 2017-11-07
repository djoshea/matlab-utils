function corddef()
% set color order to default

    cord = get(groot, 'FactoryAxesColorOrder');
    set(groot, 'DefaultAxesColorOrder', cord);
    set(gca, 'ColorOrder', cord);

end
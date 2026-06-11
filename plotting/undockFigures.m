function undockFigures()
% undock all open figures and set figures to be undocked by default
    set(0, 'DefaultFigureWindowStyle', 'normal');
    figs = findobj('Type', 'figure');
    set(figs, 'WindowStyle', 'normal');
end
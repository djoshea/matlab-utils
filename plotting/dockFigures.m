function dockFigures()
% dock all open figures and set figures to dock automatically
    set(0, 'DefaultFigureWindowStyle', 'docked');
    figs = findobj('Type', 'figure');
    set(figs, 'WindowStyle', 'docked');

end
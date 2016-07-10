function figShowMenu(figh)
    if nargin < 1
        figh = gcf;
    end
   
    set(figh, 'MenuBar', 'figure');
    set(figh, 'ToolBar', 'auto');
    set(figh, 'DockControls', 'on');
end
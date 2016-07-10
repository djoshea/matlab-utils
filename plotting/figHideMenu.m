function figHideMenu(figh)
    if nargin < 1
        figh = gcf;
    end
   
    set(figh, 'MenuBar', 'none');
    set(figh, 'ToolBar', 'none');
    set(figh, 'DockControls', 'off');
end
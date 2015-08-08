function figHideMenu(figh)
    if nargin < 1
        figh = gcf;
    end
   
    set(figh, 'MenuBar', 'none');
end
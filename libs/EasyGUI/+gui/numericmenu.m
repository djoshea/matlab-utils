% gui.numericmenu
%    A widget that displays a drop-down menu of numbers
%
%    w = gui.numericmenu creates a widget that displays a
%    drop-down menu, with the menu items restricted to be 
%    numbers. The widget is added to the current autogui 
%    (if there is no current autogui, one is created). 
%
%    w = gui.numericmenu(M) creates the widget with the label
%    string M.
%
%    w = gui.numericmenu(M,S) creates the widget with the label
%    string M, and menu items S (a vector of numbers).
%
%    w = gui.numericmenu(M,S,G) creates the widget with the
%    label string M and menu items S, and adds it to the gui
%    container G.
%
%  Sample usage:
%     g = gui.autogui;
%    w1 = gui.numericmenu;
%    w2 = gui.numericmenu('Sample rate', [8000 11025 22050 44100]);
%    w3 = gui.numericmenu('Sample rate', [8000 11025 22050 44100], g);
%
%    Also see: 
%    <a href="matlab:help gui.numericmenu.Value">gui.numericmenu.Value</a>
%    <a href="matlab:help gui.textmenu">gui.textmenu</a>
%    <a href="matlab:help gui.listbox">gui.listbox</a>

%   Copyright 2009 The MathWorks, Inc.

classdef (Sealed) numericmenu < gui.labeleduicontrol

    properties(Dependent)
        % Value 
        %   A number indicating the current menu selection. The MenuItems
        %   property specifies the list of choices. 
        %
        %   Sample usage:
        %    s = gui.numericmenu('Choose sample size', [128 256 512 1024]);
        %    if s.Value == 256 % get the value
        %       % ...
        %    end
        %    s.Value = 512;  % set the current selection
        %    % invalid assignment, since 16 is not one of the menu options
        %    s.Value = 16;   
        Value 
    end        
    
    properties (Dependent)
        % MenuItems
        %   A numeric vector specifying the menu options. Whenever
        %   the MenuItems property is modified, the Value property is reset
        %   to the first item in the array.
        %
        %   Sample usage:
        %    initialMenuItems = [64 128 512];
        %    s = gui.numericmenu('Choose a filter', initialMenuItems);
        %    % change the menu items
        %    s.MenuItems = [1024 2048 4096 8192];
        %    s.Value % automatically reset to 1024
        MenuItems
    end
    
    properties(Access=private)
        NumericList
    end
    
    methods
        function obj = numericmenu(labelStr, menuItems, varargin)

            if ~exist('labelStr', 'var')
                labelStr = 'Choose a menu item';
            end
            if ~exist('menuItems', 'var')
                menuItems = [2 4 8 16 32 64];
            end
            
            obj = obj@gui.labeleduicontrol('popupmenu',labelStr,varargin{:});
            assert(~obj.Initialized && ~obj.Visible);
            obj.MenuItems = menuItems;
            
            obj.Initialized = true;
            obj.Visible = true;            
        end
        
    end

    methods
        % resets value, but does not notify ValueChanged
        function set.MenuItems(obj, itemList)
            if ~(isnumeric(itemList) && isvector(itemList))
                throw(MException('numericmenu:InvalidMenuItems', 'MenuItems should be a numeric vector'));
            end
            % get unique items in the same order as their occurrence in itemlist
            [uniqueItems,indices] = unique(itemList,'first');
            if numel(uniqueItems) < numel(itemList)
                warning('numericmenu:DuplicateMenuItems', 'Ignoring duplicate menu items');
                itemList = itemList(sort(indices));
            end         
            obj.NumericList = itemList;
            itemStringList = cellfun(@num2str, num2cell(itemList), 'uniformoutput',false);
            set(obj.UiControl,'String', itemStringList);
            set(obj.UiControl, 'Value', 1);
        end

        function out = get.MenuItems(obj)
            out = obj.NumericList;
        end
        
        function set.Value(obj , val)
            items = obj.MenuItems;
            if isnumeric(val) && isscalar(val)
                index = find(val == obj.NumericList);
            else
                index = [];
            end

            if isempty(index)                
                itemsString = sprintf(' %g\n', items);                
                throw(MException('numericmenu:InvalidValue', ...
                    'Value should match one of the menu items:\n%s', ...
                    itemsString));
            end

            set(obj.UiControl,'Value', index(1));
            notify(obj, 'ValueChanged');
        end
        
        function out = get.Value(obj)
            index = get(obj.UiControl, 'Value');
            out = obj.NumericList(index);
        end
    end
    
    methods(Access=protected)
       
        function initNotify(obj)
            initNotify@gui.labeleduicontrol(obj);
            obj.LabelLocation = 'above';
        end
        
    end
               
end


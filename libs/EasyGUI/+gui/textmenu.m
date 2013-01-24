% gui.textmenu
%    A widget that displays a drop-down menu 
%
%    w = gui.textmenu creates a widget that displays a
%    drop-down menu. The widget is added to the current autogui 
%    (if there is no current autogui, one is created). 
%
%    w = gui.textmenu(M) creates the widget with the label
%    string M.
%
%    w = gui.textmenu(M,S) creates the widget with the label
%    string M, and menu items S (a cell array of strings).
%
%    w = gui.textmenu(M,S,G) creates the widget with the
%    label string M and menu items S, and adds it to the gui
%    container G.
%
%  Sample usage:
%     g = gui.autogui;
%    w1 = gui.textmenu;
%    w2 = gui.textmenu('Filter type', {'Lowpass', 'Highpass'});
%    w3 = gui.textmenu('Filter type', {'Lowpass', 'Highpass'}, g);
%
%    Also see: 
%    <a href="matlab:help gui.textmenu.Value">gui.textmenu.Value</a>
%    <a href="matlab:help gui.numericmenu">gui.numericmenu</a>
%    <a href="matlab:help gui.listbox">gui.listbox</a>

%   Copyright 2009 The MathWorks, Inc.

classdef (Sealed) textmenu < gui.labeleduicontrol

    properties(Dependent)
        % Value 
        %   A string indicating the current menu selection. The MenuItems
        %   property specifies the list of choices.
        % 
        %   Sample usage:
        %    s = gui.textmenu('Choose a filter', {'Lowpass', 'Highpass', 'Bandpass'});
        %    if strcmp(s.Value, 'Lowpass')  % get the value
        %          % ...
        %    end
        %    s.Value = 'Bandpass';  % set the current selection
        %    % invalid assignment, since 'Notch' is not one of the menu options
        %    s.Value = 'Notch';   
        Value 
    end
    
    properties(Dependent)
        % MenuItems
        %   A cell array of strings specifying the menu options. Whenever
        %   the MenuItems property is modified, the Value property is reset
        %   to the first item in the array.
        %
        %   Sample usage:
        %    initialMenuItems = {'Lowpass', 'Highpass'};
        %    s = gui.textmenu('Choose a filter', initialMenuItems);
        %    % change the menu items
        %    s.MenuItems = {'Lowpass-1', 'Lowpass-2', 'Lowpass-3'};
        %    s.Value % automatically reset to 'Lowpass-1'
        MenuItems
    end
    
    methods
        function obj = textmenu(labelStr, menuItems, varargin)

            if ~exist('labelStr', 'var')
                labelStr = 'Choose a menu item';
            end
            if ~exist('menuItems', 'var')
                menuItems = {'Option 1', 'Option 2', 'Option 3'};
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
            if isempty(itemList) || ~(ischar(itemList) || iscellstr(itemList))
                throw(MException('textmenu:InvalidMenuItems', 'MenuItems should be a string or a cell array of strings'));
            end
            itemList = cellstr(itemList);
            % get unique items in the same order as their occurrence in itemlist
            [uniqueItems,indices] = unique(itemList,'first');
            if numel(uniqueItems) < numel(itemList)
                warning('textmenu:DuplicateMenuItems', 'Ignoring duplicate menu items');
                itemList = itemList(sort(indices));
            end
            set(obj.UiControl,'String', itemList);
            set(obj.UiControl, 'Value', 1);
        end

        function out = get.MenuItems(obj)
            out = get(obj.UiControl, 'String');
        end
        
        function set.Value(obj , val)
            items = obj.MenuItems;
            if ischar(val)
                index = strmatch(val, items);
            else
                index = [];
            end

            if isempty(index)
                itemsString = sprintf(' ''%s''\n', items{:});                
                throw(MException('textmenu:InvalidValue', ...
                    'Value should match one of the menu items:\n%s', ...
                    itemsString));
            end

            set(obj.UiControl,'Value', index(1));
            notify(obj, 'ValueChanged');
        end
        
        function out = get.Value(obj)
            index = get(obj.UiControl, 'Value');
            items = obj.MenuItems;
            out = items{index};
        end
    end

    
    methods(Access=protected)
       
        function initNotify(obj)
            initNotify@gui.labeleduicontrol(obj);
            obj.LabelLocation = 'above';
        end
        
    end    
        
end


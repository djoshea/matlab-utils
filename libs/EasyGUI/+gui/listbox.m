% gui.listbox
%    A widget for selecting from a scrollable list
%
%    w = gui.listbox creates a widget that displays a
%    scrollable list and allows the user to select one or more
%    items in it. The widget is added to the current
%    autogui (if there is no current autogui, one is created).
%
%    w = gui.listbox(M) creates the widget with the label
%    string M.
%
%    w = gui.listbox(M,S) creates the widget with the label
%    string M, and list S (a cell array of strings).
%
%    w = gui.listbox(M,S,G) creates the widget with the
%    label string M and list S, and adds it to the gui
%    container G.
%
%  Sample usage:
%     g = gui.autogui;
%    w1 = gui.listbox;
%    w2 = gui.listbox('Filter type', {'Lowpass', 'Highpass'});
%    w3 = gui.listbox('Filter type', {'Lowpass', 'Highpass'}, g);
%
%    Also see: 
%    <a href="matlab:help gui.listbox.Value">gui.listbox.Value</a>
%    <a href="matlab:help gui.textmenu">gui.textmenu</a>
%    <a href="matlab:help gui.numericmenu">gui.numericmenu</a>

%   Copyright 2009 The MathWorks, Inc.

classdef (Sealed) listbox < gui.labeleduicontrol

    properties(Dependent)
        % Value 
        %   A string or cell array of strings indicating the current list
        %   selection (the MenuItems property specifies items of the list). 
        %
        %   Sample usage:
        %    s = gui.listbox('Choose colors', {'Red', 'Green', 'Blue', 'Yellow'});
        %
        %    s.AllowMultipleSelections = true;
        %    s.Value % get the value (a cell array of strings)
        %    s.Value = {'Red', 'Blue'}; % set the value
        %    s.Value = []; % clear all selections
        %
        %    s.AllowMultipleSelections = false;
        %    s.Value % get the value (a string)
        %    s.Value = 'Green'; % set the value
        Value 
    end
    
    properties(Dependent)
        % MenuItems
        %   A cell array of strings specifying the items of the list. Whenever
        %   the MenuItems property is modified, the Value property is reset
        %   to the first item in the list.
        %
        %   Sample usage:
        %    initialColors = {'Red', 'Green'};
        %    s = gui.listbox('Choose a color', initialColors);
        %    % change the menu items
        %    s.MenuItems = {'Yellow', 'Blue', 'Black', 'Red'};
        %    s.Value % automatically reset to 'Yellow'        
        MenuItems
        
        % AllowMultipleSelections
        %   A boolean that indicates whether multiple list items can be
        %   selected or not.
        %
        %   true  => Multiple list items can be selected (using
        %            Ctrl-Click). The Value property returns a 
        %            cell array of strings. 
        %   false => Only one list item can be  selected at a time. The
        %            Value property returns a string.
        %
        %   Sample usage:
        %    s = gui.listbox('Choose colors', {'Red', 'Green', 'Blue', 'Yellow'});
        %    s.AllowMultipleSelections = false;
        AllowMultipleSelections
    end
    
    methods
        function obj = listbox(labelStr, menuItems, varargin)
            
            if ~exist('labelStr', 'var')
                labelStr = 'Choose one or more menu items';
            end
            if ~exist('menuItems', 'var')
                menuItems = {'Option 1', 'Option 2', 'Option 3'};
            end

            obj = obj@gui.labeleduicontrol('listbox',labelStr,varargin{:});
            assert(~obj.Initialized && ~obj.Visible);
            
            % Later calls to setSizeInFlow(...) etc.
            % assume UiHandle is a uiflowcontainer
            assert(strcmp(get(obj.UiHandle,'type'), 'uiflowcontainer'));
            
            set(obj.UiControl,'Min',0);

            obj.MenuItems = menuItems;
            obj.AllowMultipleSelections = true;
            
            obj.Initialized = true;
            obj.Visible = true;
            
        end

    end
    
    methods
        function set.MenuItems(obj, itemList)
            if ~(ischar(itemList) || iscellstr(itemList))
                throw(MException('menu:set', 'MenuItems should be a string or a cell array of strings'));
            end
            itemList = cellstr(itemList);
            % get unique items in the same order as their occurrence in itemlist
            [uniqueItems,indices] = unique(itemList,'first');
            if numel(uniqueItems) < numel(itemList)
                warning('listbox:DuplicateMenuItems', 'Ignoring duplicate menu items');
                itemList = itemList(sort(indices));
            end
            set(obj.UiControl,'String', itemList);
            obj.Value = itemList{1};
        end

        function out = get.MenuItems(obj)
            out = get(obj.UiControl, 'String');
        end
    
        function out = get.AllowMultipleSelections(obj)
            out = get(obj.UiControl,'Max') > 1;
        end

        function set.AllowMultipleSelections(obj,val)
            if val
                set(obj.UiControl,'Max',2);
            else
                set(obj.UiControl,'Max',1);
            end
        end
        
        % Set the Value property to an empty matrix [] to have no selection
        % if mult. sel, value can be a vector of indices 
        
        function out = get.Value(obj)
            
            indices = get(obj.UiControl, 'Value');
            items = obj.MenuItems;
             if obj.AllowMultipleSelections
                 out = items(indices);
             else
                 out = items{indices};
             end
         end
        
        function set.Value(obj , val)
            items = obj.MenuItems;
            allowMultipleSel = obj.AllowMultipleSelections;
            try                
                if ~(isempty(val) || ischar(val) || iscellstr(val))
                    throw(MException('listbox:InvalidValue','Invalid value'));
                end
                if ~isempty(val)
                    val = cellstr(val);
                end
                if numel(val) > 1,
                    val = unique(val); 
                end
                if ~allowMultipleSel && (numel(val) ~= 1)
                    throw(MException('listbox:InvalidValue','Invalid value'));
                end
                % convert val to list of indices
                indices = zeros(1,numel(val));
                for i = 1:numel(val)
                    index = strmatch(val{i}, items, 'exact');
                    if isempty(index)
                        throw(MException('listbox:InvalidValue','Invalid value'));
                    end
                    indices(i) = index; 
                end
            catch ME %#ok<NASGU>
                if strcmp(ME.identifier,'listbox:InvalidValue')
                    throw(MException('listbox:InvalidValue', ...
                        'Value should be a a single string (multiple selections are not allowed)'));
                else
                    itemsString = sprintf(' ''%s''\n', items{:});
                    throw(MException('listbox:InvalidValue', ...
                        'Values should match one of the menu items:\n%s', ...
                        itemsString));
                end
            end

            set(obj.UiControl,'Value', indices);
            notify(obj, 'ValueChanged');
        end
        
    end

    methods(Access=protected)
        
        % called upon initialization
        function initNotify(obj)
            initNotify@gui.labeleduicontrol(obj);
            
            % figure out the default height of the listbox
            % the +0.5 is just a layout adjustment tweak
            labelSize = get(obj.UiLabel, 'Extent'); % [0 0 width height]
            obj.Position = struct('height', (numel(obj.MenuItems)+0.8) * labelSize(4) + 10);
            
            obj.LabelLocation = 'above';
        end

        
        % override method
        % pos is a vector [x y w h]        
        function postPositionChange(obj, pos)
            nans = isnan(pos(3:4));
            if all(nans), return; end
            if nans(1)
                pos(3) = obj.getPositionWidth();
            end
            if nans(2)
                pos(4) = obj.getPositionHeight();
            end
            w = pos(3); h = pos(4);
            
            switch obj.LabelLocation
                case 'none'
                    labelpos = [];
                    ctrlpos = [round(0.95 * w)  round(0.97 * h)];
                case {'above','below'}
                    labelSizeNeeded = get(obj.UiLabel,'extent'); % [0 0 width height]
                    labelratio = min(0.45, labelSizeNeeded(4) / h);
                    ctrlratio = 1-labelratio-0.1;
                    labelpos = [round(0.95 * w) round(labelratio * h)];
                    ctrlpos =  [round(0.95 * w) round(ctrlratio * h)];
                case {'left', 'right'}
                    labelpos = [round(0.55 * w) round(0.90 * h)];
                    ctrlpos =  [round(0.40 * w) round(0.90 * h)];
            end
            
            % we know UiControl and UiLabel are in a flowcontainer
            gui.util.uiposition.setSizeInFlow(obj.UiControl, ctrlpos);            
            if ~isempty(labelpos)
                gui.util.uiposition.setSizeInFlow(obj.UiLabel, labelpos);
            end                            
        end
        
    end
    

    
end

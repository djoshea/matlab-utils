% gui.togglebutton
%    A widget with a button that be toggled on or off.
%
%    w = gui.togglebutton creates a widget that displays a pushbutton that
%    be toggled on or off. If the button is clicked once, the button is
%    "pushed in" (the "on" position); if clicked again, the button is
%    "popped out" (the "off" position). The widget is added to the current
%    autogui (if there is no current autogui, one is created). 
%
%    w = gui.togglebutton(M) creates the widget with the label
%    string M.
%
%    w = gui.togglebutton(M,G) creates the widget with the
%    label string M and adds it to the gui container G.
%
%  Sample usage:
%     g = gui.autogui;
%    w1 = gui.togglebutton;
%    w2 = gui.togglebutton('Apply preemphasis');
%    w3 = gui.togglebutton('Apply preemphasis', g);
%
%    Also see: 
%    <a href="matlab:help gui.togglebutton.Value">gui.togglebutton.Value</a>
%    <a href="matlab:help gui.pushbutton">gui.pushbutton</a>
%    <a href="matlab:help gui.checkbox">gui.checkbox</a>

%   Copyright 2009 The MathWorks, Inc.

classdef (Sealed) togglebutton < gui.labeleduicontrol

    properties(Dependent)
        % Value 
        %   A boolean indicating the state of the toggle button.
        %     true => box is pushed in
        %     false => box is not pushed in 
        %
        %   Sample usage:
        %    s = gui.togglebutton('Prefilter the signal');
        %    if s.Value % get the value
        %       % ...
        %    end
        %    s.Value = false;  % clear the toggle
        Value 
    end
    
    methods
        function obj = togglebutton(labelStr, varargin)
            if ~exist('labelStr', 'var')
                labelStr = 'Toggle Button';
            end
            
            obj = obj@gui.labeleduicontrol('togglebutton',labelStr,varargin{:});
            assert(~obj.Initialized && ~obj.Visible);
                        
            obj.Initialized = true;
            obj.Visible = true;
        end
        
    end

    methods
        
        function set.Value(obj , val)
            if islogical(val) || (isscalar(val) && isnumeric(val) && isreal(val))
                set(obj.UiControl,'Value', logical(val));
            else
                throw(MException('togglebutton:InvalidValue', 'Value should be true(1) or false(0)'));
            end
            notify(obj, 'ValueChanged');
        end
        
        function out = get.Value(obj)
            out = logical(get(obj.UiControl, 'Value'));
        end
    end
        
    
    methods(Access=protected)
        
        function initNotify(obj)
            initNotify@gui.labeleduicontrol(obj);
            set(obj.UiControl, 'String', get(obj.UiLabel,'String'));
            obj.LabelLocation = 'none';
        end
        
        
        function postLabelChange(obj, str)
            set(obj.UiControl, 'String', str);
        end
    end
    
    methods(Hidden)
        function uicontrolCallback(obj)
            notify(obj, 'ValueChanged');
        end
        
    end
    
end


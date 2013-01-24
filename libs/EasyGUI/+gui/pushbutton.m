% gui.pushbutton
%    A widget with a simple push button.
%
%    w = gui.pushbutton creates a widget that displays a button. When
%    the button is pressed, the button is "on" for 100 msec and then
%    resets automatically. The widget is added to the current
%    autogui (if there is no current autogui, one is created). 
%
%    w = gui.pushbutton(M) creates the widget with the label
%    string M.
%
%    w = gui.pushbutton(M,G) creates the widget with the
%    label string M and adds it to the gui container G.
%
%  Note: This widget is best used with the ValueChangedFcn property.
%  Because the widget Value resets automatically, polling it in a loop can
%  cause button presses to be missed.
%
%  Sample usage:
%     g = gui.autogui;
%    w1 = gui.pushbutton;
%    w2 = gui.pushbutton('Start simulation');
%    w3 = gui.pushbutton('Start simulation', g);
%
%    Also see: 
%    <a href="matlab:help gui.pushbutton.Value">gui.pushbutton.Value</a>
%    <a href="matlab:help gui.pushbutton.ValueChangedFcn">gui.pushbutton.ValueChangedFcn</a>
%    <a href="matlab:help gui.togglebutton">gui.togglebutton</a>
%    <a href="matlab:help gui.checkbox">gui.checkbox</a>

%   Copyright 2009 The MathWorks, Inc.

classdef (Sealed) pushbutton < gui.labeleduicontrol

    properties(Dependent)
        % Value -- A boolean indicating the state of the pushbutton
        %   true => the button was pressed inn the last 100 msec.
        %   false => the button hasn't been pressed within the last 100 msec
        %
        %  Value can also be set programmatically, e.g.,
        %    b = gui.pushbutton('My Button');
        %    b.Value = true;
        %    b.Value = false;
        %  Setting Value to true is equivalent to a button press.
        %  Setting Value to false is equivalent to clearing out a prior
        %  button press.        
        Value  
    end
    
    properties(Access=private)
        LastClickTime = []
    end

    properties(Constant,Access=private)
        ElapsedTimeThreshold = 0.1 % in seconds
    end
    
    methods
        function obj = pushbutton(labelStr, varargin)
            if ~exist('labelStr', 'var')
                labelStr = 'Pushbutton';
            end
            
            obj = obj@gui.labeleduicontrol('pushbutton',labelStr,varargin{:});
            assert(~obj.Initialized && ~obj.Visible);                                    
            
            obj.Initialized = true;
            obj.Visible = true;
        end
        
    end

    methods
        
        function set.Value(obj , val)
            if isscalar(val) && (isnumeric(val) || islogical(val))
                if logical(val) 
                    % true -- simulate the button being pressed anew
                    uicontrolCallback(obj);
                else % false 
                    obj.LastClickTime  = [];
                end
            else
                throw(MException('pushbutton:set', 'Value should be true or false'));
            end
        end
        
        function out = get.Value(obj)
            out = ~isempty(obj.LastClickTime) && ...
                  (etime(clock, obj.LastClickTime) <= obj.ElapsedTimeThreshold);
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
            obj.LastClickTime = clock;
            notify(obj, 'ValueChanged');
        end
        
    end
    
end


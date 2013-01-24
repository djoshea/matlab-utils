% gui.checkbox
%    A checkbox widget that be toggled on or off.
%
%    W = gui.checkbox creates a checkbox widget and adds it to
%    the current autogui (if there is no current autogui, one
%    is created).
%
%    W = gui.checkbox(M) creates a checkbox widget with the
%    label string M.
%
%    W = gui.checkbox(M,G) creates a checkbox widget with the
%    label string M, and adds it to the gui container G.
%
%  Sample usage:
%     g = gui.autogui;
%    w1 = gui.checkbox;
%    w2 = gui.checkbox('Apply preemphasis');
%    w3 = gui.checkbox('Apply preemphasis',g);
%
%  Also see: 
%   <a href="matlab:help gui.checkbox.Value">gui.checkbox.Value</a>
%   <a href="matlab:help gui.togglebutton">gui.togglebutton</a>

%   Copyright 2009 The MathWorks, Inc.

classdef (Sealed) checkbox < gui.labeleduicontrol

    properties(Dependent)
        % Value 
        %   A boolean indicating the state of the checkbox.
        %     true => box is checked
        %     false => box is unchecked. 
        %
        %   Sample usage:
        %    s = gui.checkbox('Prefilter the signal');
        %    if s.Value % get the value
        %       % ...
        %    end
        %    s.Value = false;  % clear the checkbox
        Value 
    end
    
    methods
        
        function obj = checkbox(labelStr, varargin)

            if ~exist('labelStr', 'var')
                labelStr = 'Checkbox';
            end
            
            obj = obj@gui.labeleduicontrol('checkbox',labelStr,varargin{:});
            % assert(~obj.Initialized && ~obj.Visible);
            
            obj.Initialized = true;
            obj.Visible = true;            
        end
        
    end

    methods
        
        function set.Value(obj , val)
            if islogical(val) || (isscalar(val) && isnumeric(val) && isreal(val))
                set(obj.UiControl,'Value', logical(val));
            else
                throw(MException('checkbox:InvalidValue', 'Value should be true(1) or false(0)'));
            end
            notify(obj, 'ValueChanged');
        end
        
        function out = get.Value(obj)
            out = logical(get(obj.UiControl, 'Value'));
        end
    end
        
        
    methods(Access=protected)
        % override
        function initNotify(obj)
            initNotify@gui.labeleduicontrol(obj);
            set(obj.UiControl, 'String', get(obj.UiLabel,'String'));
            obj.LabelLocation = 'none';            
        end
        
        % override
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


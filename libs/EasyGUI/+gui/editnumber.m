% gui.editnumber
%    A text input widget that only accepts numbers.
%
%    w = gui.editnumber creates a widget for entering numbers
%    and adds it to the current autogui (if there is no current
%    autogui, one is created).
%
%    w = gui.editnumber(m) creates the widget with the label
%    string m.
%
%    w = gui.editnumber(m, g) creates the widget with the
%    label string m, and adds it to the gui container g.
%
%  Sample usage:
%     g = gui.autogui;
%    w1 = gui.editnumber;
%    w2 = gui.editnumber('Frequency (Hz)');
%    w3 = gui.editnumber('Frequency (Hz)',g);
%
%    Also see: 
%    <a href="matlab:help gui.editnumber.Value">gui.editnumber.Value</a>
%    <a href="matlab:help gui.numericmenu">gui.numericmenu</a>

%   Copyright 2009 The MathWorks, Inc.

classdef (Sealed) editnumber < gui.labeleduicontrol
    properties(Dependent)
        % Value 
        %   The number entered by the user. This property can also be set
        %   programmatically. 
        %
        %   Sample usage:
        %    s = gui.editnumber('Number of samples');
        %    s.Value % get the value
        %    s.Value = s.Value + 100; % increment the value
        Value
    end    
    
    properties(Access=private)
        OldString = '0.0'
    end
    
    % Main Constructor
    methods
        function obj = editnumber(labelStr, varargin)            
            if ~exist('labelStr', 'var')
                labelStr = 'Enter a number:';
            end
            
            obj = obj@gui.labeleduicontrol('edit',labelStr,varargin{:});
            % assert(~obj.Initialized && ~obj.Visible);
            % assert(strcmp(obj.LabelLocation, 'above'));
            
            set(obj.UiControl, 'BackgroundColor', [0.95 .95 .95]);
            obj.Value = 0;
            
            % obj is the most derived class
            obj.Initialized = true;
            obj.Visible = true;
        end
    end
    
    % Interface to properties
    methods 
        function set.Value(obj,val)
            ensureValidNumber(val, 'Value');            
            newStr = num2str(val,10);
            set(obj.UiControl,'String',newStr);
            obj.OldString = newStr;
            notify(obj,'ValueChanged');
        end
        
        function out = get.Value(obj)
            out = str2double(get(obj.UiControl,'String'));            
        end
    end

    methods (Hidden)       
        function uicontrolCallback(obj)
            newStr = get(obj.UiControl, 'string');
            newVal = str2double(newStr);
            if isnan(newVal) || ~ensureValidNumber(newVal)
                set(obj.UiControl, 'string', obj.OldString);
            else
                obj.OldString = newStr;
                notify(obj, 'ValueChanged');
            end
        end
            
    end
    
end


function valueOkay = ensureValidNumber(val, str)
valueOkay = isscalar(val) && isnumeric(val) && isreal(val) && ~isnan(val);
if nargout==0 && ~valueOkay
    throwAsCaller(MException('editnumber:InvalidValue', '%s should be a real number', str));
end
end

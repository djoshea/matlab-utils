% gui.edittext
%    A widget for entering and editing single-line text
%
%    w = gui.edittext creates a widget for entering and
%    editing single-line text, and adds it to the current
%    autogui (if there is no current autogui, one is created).
%
%    w = gui.edittext(m) creates the widget with the label
%    string m.
%
%    w = gui.edittext(m, g) creates the widget with the
%    label string m, and adds it to the gui container g.
%
%  Sample usage:
%     g = gui.autogui;
%    w1 = gui.edittext;
%    w2 = gui.edittext('Your name');
%    w3 = gui.edittext('Your name',g);
%
%    Also see: 
%    <a href="matlab:help gui.edittext.Value">gui.edittext.Value</a>
%    <a href="matlab:help gui.textmenu">gui.textmenu</a>

%   Copyright 2009 The MathWorks, Inc.

classdef (Sealed) edittext < gui.labeleduicontrol
    properties(Dependent)
        % Value 
        %   The string entered by the user. This property can also be set
        %   programmatically.
        %
        %   Sample usage:
        %    s = gui.edittext('Enter your name');
        %    s.Value % get the value
        %    s.Value = 'Clark Kent'; % set the value        
        Value
    end    
    
    % Main Constructor
    methods
        function obj = edittext(labelStr, varargin)
            if ~exist('labelStr', 'var')
                labelStr = 'Enter a value:';
            end
            
            obj = obj@gui.labeleduicontrol('edit',labelStr,varargin{:});
            % assert(~obj.Initialized && ~obj.Visible);
            % assert(strcmp(obj.LabelLocation, 'above'));
            
            set(obj.UiControl, 'BackgroundColor', 'w');
            obj.Value = '';
            
            % obj is the most derived class
            obj.Initialized = true;
            obj.Visible = true;
        end
    end
    
    % Interface to properties
    methods 
        function set.Value(obj,val)
            if ~ischar(val)
                throw(MException('edittext:InvalidValue', 'Value should be a string'));
            end
            set(obj.UiControl,'String',val);
            notify(obj,'ValueChanged');
        end
        
        function out = get.Value(obj)
            out = get(obj.UiControl,'String');
        end
    end

end

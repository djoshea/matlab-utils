% gui.slider
%    A widget that displays an adjustable slider
%
%    w = gui.slider creates a widget that displays an adjustable slider and
%    an associated numeric entry field (changes to the slider are reflected
%    in the number field and vice versa). The widget is added to the
%    current autogui  (if there is no current autogui, one is created). 
%
%    w = gui.slider(M) creates the widget with the label string M.
%
%    w = gui.slider(M,R) creates the widget with the label string M, and
%    range R. R is a a two-element vector, [minValue maxValue].
%
%    w = gui.slider(M,R,G) creates the widget with the label string M and
%    range R, and adds it to the gui container G.
%
%  Sample usage:
%     g = gui.autogui;
%    w1 = gui.slider;
%    w2 = gui.slider('Preemphasis', [0 1]);
%    w3 = gui.slider('Preemphasis', [0 1], g);
%
%    Also see: 
%    <a href="matlab:help gui.slider.Value">gui.slider.Value</a>
%    <a href="matlab:help gui.numericmenu">gui.numericmenu</a>
%    <a href="matlab:help gui.listbox">gui.listbox</a>

%   Copyright 2009 The MathWorks, Inc.

classdef (Sealed) slider < gui.labeledwidget

    properties(Dependent)
        % Value 
        %   A number indicating the current position of the slider.
        %   The permissible range of numbers is specified by the ValueRange
        %   property.
        %   Sample usage:
        %    s = gui.slider('Choose a Frequency (Hz)');
        %    s.ValueRange = [100 2000];
        %    s.Value = 500; % set the slider to the 500 Hz location
        %    s.Value % get the value
        Value
    end
    
    properties (Dependent, SetObservable)

        % ValueRange - Specifies the range of allowed slider values
        %
        %   ValueRange is a two element vector, [minValue maxValue], that
        %   indicates the values of the leftmost and rightmost slider
        %   positions. 
        %
        %   Sample usage:
        %    w = gui.slider;
        %    w.ValueRange = [50 200];
        ValueRange
        
        % Enable - Specifies whether the widget is active or not.
        %
        %   Enable is a boolean property (true/false).     
        %    true => user can modify the state of the widget 
        %           (e.g., enter text into a field, move a slider)
        %    false => the widget is "grayed out" and cannot be modified.
        %
        %   Sample usage:
        %    w = gui.slider;
        %    w.Enable = false;          
        Enable        
    end
        
    properties(Access=private)
        UiControl
        UiFlowContainer
        UiNumberEdit        
    end
    
    methods
        function obj = slider(labelStr, range, varargin)
            
           if ~exist('labelStr', 'var')
               labelStr = 'Choose a value:';
           else
               if ~ischar(labelStr)
                   throw(MException('slider:InvalidParameter', ...
                       'Label must be a character string (e.g., ''Choose value:'''));
               end
           end
           if ~exist('range', 'var')
               range = [0 1];
           else
               validateRange(range);
           end
           initialValue = mean(range);
           
            obj = obj@gui.labeledwidget(labelStr,varargin{:});            
            assert(~obj.Initialized && ~obj.Visible);
            
            % Later calls to setSizeInFlow(...) and getHeightInFlow()
            % assume UiHandle is a uiflowcontainer            
            assert(strcmp(get(obj.UiHandle,'type'), 'uiflowcontainer'));
            
            color = obj.getParentUiColor();
            obj.UiFlowContainer = gui.util.uiflowcontainer('parent', obj.UiHandle, ...
                'FlowDirection', 'lefttoright');
            
            obj.UiNumberEdit = uicontrol('Style', 'edit', ...
                'string', num2str(initialValue), ...
                'BackgroundColor', 'w', ...
                'parent', obj.UiFlowContainer, ...
                'tag', 'slider-uinumberedit', ...
                'callback', @(h,e) editCallback(obj));
                    
            obj.UiControl = uicontrol( 'Style','slider','Parent',obj.UiFlowContainer,...
                'BackgroundColor',color,...   
                'units', 'pixels', ...                
                'min', range(1), ...
                'max', range(2), ...
                'value', initialValue, ...
                'HorizontalAlignment', 'Left', ...                
                'HandleVisibility', 'off', ...
                'tag', 'slider-uicontrol', ...
                'callback', @(h,e) propagateValueChange(obj));
                                                            
            obj.Initialized = true;
            obj.Visible = true;
        end
    end
    
    % Interface to properties
    methods 
        function set.Enable(obj,makeEnable)
            if makeEnable
                set(obj.UiControl,'Enable','on');
            else
                set(obj.UiControl,'Enable','off');
            end
        end
        
        function out = get.Enable(obj)
            out = strcmp(get(obj.UiControl,'Enable'), 'on');
        end
        
        
        function set.Value(obj,val)
            ensureValidNumber(val, 'Value');
            range = obj.ValueRange;
            if val < range(1) || val > range(2)
                throw(MException('slider:InvalidValue', ...
                    'Value should be between MinValue (%g) and MaxValue (%g)', range(1), range(2)));
            end
            set(obj.UiControl,'Value',val);
            propagateValueChange(obj);
        end
        
        function out = get.Value(obj)
            out = get(obj.UiControl,'Value');
        end
        
        function set.ValueRange(obj, range)            
            validateRange(range);
            v = get(obj.UiControl, 'Value');
            if (v < range(1))
                newval = range(1);
                warning('slider:ValueReset', 'Value set to new MinValue (%g)', newval);
                propagateValueChange(obj);
            elseif (v > range(2))
                newval = range(2);
                warning('slider:ValueReset', 'Value set to new MaxValue (%g)', newval);                
            else
                newval = v;
            end
            set(obj.UiControl,'Min', range(1), 'Max', range(2), 'Value', newval);
            if v ~= newval
                propagateValueChange(obj);
            end
        end
        
        function out = get.ValueRange(obj)
            out = [get(obj.UiControl, 'Min') get(obj.UiControl, 'Max')];
        end
        
    end
    
    methods (Hidden)
        function editCallback(obj)
            newVal = str2double(get(obj.UiNumberEdit, 'string'));
            currentVal = get(obj.UiControl, 'value');
            if isnan(newVal) || ~ensureValidNumber(newVal)
                set(obj.UiNumberEdit, 'string', num2str(currentVal));
            else
                range = obj.ValueRange;
                newVal = min(max(newVal, range(1)), range(2));
                set(obj.UiControl, 'Value', newVal);
                propagateValueChange(obj);
            end
        end
 
        function propagateValueChange(obj)
            v = get(obj.UiControl, 'value');
            set(obj.UiNumberEdit, 'String', num2str(v));
            notify(obj, 'ValueChanged');
        end
        
    end    
    
    methods (Access=protected)
        
        % called upon initialization
        function initNotify(obj)
            initNotify@gui.labeledwidget(obj);

            labelSize = get(obj.UiLabel, 'Extent'); % [0 0 width height]            
            obj.Position = struct('width',  ceil(1.5*labelSize(3)), ...
                                  'height', 2*ceil(1.1*labelSize(4)) );
            
            obj.LabelLocation = 'above';
        end
        
        % override method
        function postLabelLocationChange(obj, labelLoc)                
            uiControlHeight = gui.util.uiposition.getHeightInFlow(obj.UiControl);            
            uiLabelHeight = gui.util.uiposition.getHeightInFlow(obj.UiControl);            
            switch labelLoc
                case 'none'
                    obj.setPositionHeight( uiControlHeight );
                case {'above','below'}
                    obj.setPositionHeight( uiLabelHeight + uiControlHeight );
                case {'left', 'right'}
                    obj.setPositionHeight( max(uiLabelHeight, uiControlHeight) );
            end             
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
                    ctrlpos = [round(0.70 * w)  round(0.95 * h)];
                    editpos = [round(0.30 * w)  round(0.95 * h)];
                case {'above','below'}
                    labelpos = [round(0.95 * w) round(0.45 * h)];
                    ctrlpos =  [round(0.70 * w) round(0.50 * h)];
                    editpos =  [round(0.25 * w) round(0.50 * h)];
                case {'left', 'right'}
                    labelpos = [round(0.30 * w) round(0.95 * h)];
                    ctrlpos =  [round(0.40 * w) round(0.95 * h)];
                    editpos =  [round(0.25 * w) round(0.95 * h)];
            end            
            
            gui.util.uiposition.setSizeInFlow(obj.UiControl, ctrlpos);            
            gui.util.uiposition.setSizeInFlow(obj.UiNumberEdit, editpos);            
            if ~isempty(labelpos)
                gui.util.uiposition.setSizeInFlow(obj.UiLabel, labelpos);
            end                      
        end
        
    end    

    
end


function valueOkay = ensureValidNumber(val, str)
valueOkay = isscalar(val) && isnumeric(val) && isreal(val) && ~isnan(val) && ~isinf(val);
if nargout==0 && ~valueOkay
    throwAsCaller(MException('slider:InvalidValue', '%s should be a real number', str));
end
end

function validateRange(range)
if ~(isnumeric(range) && numel(range)==2)
    throw(MException('slider:InvalidRange', ...
        ['ValueRange should be of the form [MinValue MaxValue]\n' ...
        'with MinValue < MaxValue and both being real numbers']));
end
ensureValidNumber(range(1), 'MinValue');
ensureValidNumber(range(2), 'MaxValue');
if range(1) >= range(2)
    throw(MException('slider:InvalidRange', 'MinValue should be smaller than MaxValue'));
end
end

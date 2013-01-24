% gui.labeleduicontrol
%
%   An abstract class for widgets with a text label and a HG uicontrol.

%   Copyright 2009 The MathWorks, Inc.

classdef labeleduicontrol < gui.labeledwidget

    properties (Dependent, SetObservable)
        %
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

    properties (Access=protected)
        UiControl = []
    end
    
    % Main Constructor/Destructor
    methods
        function obj = labeleduicontrol(style,labelStr,varargin)

            if ~exist('labelStr','var')
                labelStr = style;
            end

            obj = obj@gui.labeledwidget(labelStr,varargin{:});
            % assert is not JIT-ed
            % assert(~obj.Initialized && ~obj.Visible); 
            
            color = obj.getParentUiColor();
                
            obj.UiControl = uicontrol( 'Style',style,'Parent',obj.UiHandle,...
                'BackgroundColor',color,...
                'units', 'pixels', ...                
                'HorizontalAlignment', 'Left', ...                
                'HandleVisibility', 'off', ...
                'String', {' '}, ... % dummy initial value
                'tag', 'labeleduicontrol-uicontrol', ...
                'callback', @(h,e) uicontrolCallback(obj));
            
            % assume UiHandle is a uiflowcontainer
            % assert(strcmp(get(obj.UiHandle,'type'), 'uiflowcontainer'));            
        end

    end

    % Interface for properties
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
        
    end

    
    methods(Access=protected)
        
        % called upon initialization
        function initNotify(obj)
            initNotify@gui.labeledwidget(obj);
            
            % set the initial size for the widget
            % for defaults, assume uicontrol is same size as UiLabel            
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
        function postPositionChange(obj, pos) %#ok<DEFNU>
            
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
                    ctrlpos = [round(0.95 * w)  round(0.95 * h)];
                case {'above','below'}
                    labelpos = [round(0.95 * w) round(0.45 * h)];
                    ctrlpos =  [round(0.95 * w) round(0.55 * h)];
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
    
    methods (Hidden)
        % obj can be overriden by a subclass
        function uicontrolCallback(obj)
            notify(obj, 'ValueChanged');
        end
    end

end

% gui.labeledwidget
%
%   An abstract class for widgets with an adjustable text label.

%   Copyright 2009 The MathWorks, Inc.

classdef labeledwidget < gui.widget

    properties (Dependent, SetObservable)
        %
        % Label - A text label or prompt associated with this GUI element
        %
        %   Label can be any valid string. 
        %   
        %   Sample usage:
        %     w = gui.slider;
        %     w.Label = 'Choose a frequency:';
        Label        
                
        %
        % LabelAlignment - The horizontal alignment of the label text
        %
        %   LabelAlignment should one of the following strings: 
        %     'left'   - the label text is left-aligned in the label box
        %     'right   - the label text is right-aligned in the label box
        %     'center' - the label text is centered in the label box
        LabelAlignment
    end
    
    properties(SetObservable)
        %
        % LabelLocation - The location of the label with respect to the GUI element
        %
        %   LabelLocation should one of the following strings: 
        %     'left'  - the label is shown to the left of the GUI element
        %     'right' - the label is shown to the right of the GUI element
        %     'above' - the label is shown above the GUI element
        %     'below' - the label is shown below the GUI element
        %   
        %   Sample usage:
        %     w = gui.slider;
        %     w.LabelLocation = 'left';        
        LabelLocation = 'above'
    end

    properties (Access=protected)
        UiLabel = []
    end

    % Main Constructor/Destructor
    methods
        function obj = labeledwidget(labelStr,varargin)

            if ~exist('labelStr','var')
                labelStr = style;
            end

            obj = obj@gui.widget(varargin{:});
            
            color = obj.getParentUiColor();
            
            % default LabelLocation is 'above' => 
            %   initial flowdirection is 'topdown'
            obj.UiHandle = gui.util.uiflowcontainer('Parent',obj.ParentUiHandle, ...
                'units', 'pixels', ...
                'BackgroundColor',color, ...
                'FlowDirection', 'topdown', ...
                'tag', 'labeledwidget-uihandle', ...
                'Visible', 'off', ...
                'DeleteFcn', @(h,e) delete(obj));    

            obj.UiLabel = uicontrol( 'Style','Text','Parent',obj.UiHandle,...
                'BackgroundColor',color,...
                'units', 'pixels', ...                
                'string', labelStr, ...
                'HorizontalAlignment', 'Left', ...
                'position', [2 2 80 25], ...
                'tag', 'labeledwidget-uilabel', ...            
                'HandleVisibility', 'off');

            assert(~obj.Initialized);            
            obj.Visible = false;            
        end

    end

    % Interface for properties
    methods

        
        function set.LabelLocation(obj,location)
            if strcmp(obj.LabelLocation, location)                
                return; % nothing to do
            end

            options =  {'left'        'above'   'right'        'below'    'none'};
            flowdirs = {'lefttoright' 'topdown' 'righttoleft'  'bottomup'};
            index = strmatch(lower(location), options, 'exact');
            if isempty(index)          
                throw(MException('set:LabelLocation', ...
                    'Location should be one of: ''left'' ''right'' ''above'' ''below'''));
            end
            location = options{index};
            
            % commit the change
            
            if strmatch(location, 'none')
                set(obj.UiLabel, 'Visible', 'off');
            else
                set(obj.UiLabel, 'Visible', 'on');
                set(obj.UiHandle,'FlowDirection',flowdirs{index});
            end
            
            obj.LabelLocation = location;            
            postLabelLocationChange(obj, location);
            
            refresh(ancestor(obj.UiHandle, 'figure'));
        end
        
        function set.Label(obj,str)
            set(obj.UiLabel,'String',str);
            postLabelChange(obj,str);
        end
        
        function out = get.Label(obj)
            out = get(obj.UiLabel,'String');
        end

        function set.LabelAlignment(obj,alignment)
            set(obj.UiLabel,'HorizontalAlignment', alignment);
        end

        function out = get.LabelAlignment(obj)
            out = get(obj.UiLabel,'HorizontalAlignment');
        end

    end

    % Overrides methods
    methods (Access = protected)
               
        % called upon initialization
        function initNotify(obj)
            % set the default size of the components 
            neededSize = get(obj.UiLabel, 'Extent'); % [0 0 width height]
            p.width = ceil(1.1*neededSize(3));
            p.height = ceil(1.1*neededSize(4));
            obj.Position = p;
        end
        
        
        function postLabelLocationChange(obj, labelLocation)
            labelPos = gui.util.uiposition(obj.UiLabel);
            switch labelLocation
                case {'none', 'left', 'right'}
                    obj.setPositionHeight(labelPos.Height);
                case {'above','below'}
                    obj.setPositionHeight(labelPos.Height * 2);
            end
        end
        
        % called after label is changed
        % str is the the new label string
        function postLabelChange(obj,str) %#ok<INUSD>
            % no-op
        end
    end

end

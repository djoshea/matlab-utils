% gui.label
%    A widget to display formatted text
%
%    W = gui.label creates a widget for displaying formatted
%    text and adds it to the current autogui (if there is no
%    current autogui, one is created).
%
%    W = gui.label(M) creates the widget with initial label
%    string M.
%
%    W = gui.label(M, G) creates the widget with the
%    label string M, and adds it to the gui container G.
%
%  Sample usage:
%     g = gui.autogui;
%    w1 = gui.label;
%    w2 = gui.label('Filter parameters');
%    w3 = gui.label('Filter parameters', g);
%    w3.Font.angle = 'normal';
%    w3.Font.size = 10;
%
%    Also see: 
%    <a href="matlab:help gui.label.Value">gui.label.Value</a>
%    <a href="matlab:help gui.edittext">gui.edittext</a>

%   Copyright 2009 The MathWorks, Inc.

classdef (Sealed) label < gui.widget

    properties (Dependent)
        % Value 
        %   A text string that is the label being displayed. This property
        %   can also be set programmatically. 
        %
        %   Sample usage:
        %    s = gui.label('Filter parameters');
        %    s.Value % get the value
        %    s.Value = 'Center frequency: 100 Hz';
        Value 
    end
    
    properties(Dependent,SetObservable)
        %
        % Alignment - The horizontal alignment of the label text
        %
        %   Alignment should one of the following strings: 
        %     'left'   - the label text is left-aligned in the label box
        %     'right   - the label text is right-aligned in the label box
        %     'center' - the label text is centered in the label box
        Alignment

        % 
        % TopMargin - The amount of blank space above the label
        %    TopMargin is the number of pixels of blank space to be
        %    maintained above the label.
        %   Sample usage:
        %    w = gui.label('Frequency parameters');
        %    w.TopMargin = 20;
        TopMargin
        
        % BottomMargin - The amount of blank space below the label
        %    TopMargin is the number of pixels of blank space to be
        %    maintained below the label.
        %   Sample usage:
        %    w = gui.label('Frequency parameters');
        %    w.BottomMargin = 20;        
        BottomMargin
                    
        % Font - The font size and style for the label
        %   Font is a struct with the following fields
        %     size  : The font size in points
        %     angle : The angle of the text. Possible values are:
        %             'normal', 'italic' or 'oblique'
        %     weight: The darkness of the text. Possible values are:
        %             'normal', 'light', 'demi', 'bold'
        %
        %   Sample usage:
        %     w = gui.label('Frequency parameters');
        %     
        %     w.Font
        %     w.Font.size
        %     
        %     w.Font.size = 11;
        %     w.Font.angle = 'italic';
        %     w.Font = struct('size', 12, 'weight', 'bold');
        %     
        %     w2 = gui.label('Frequency parameters');
        %     w2.Font = w.Font;
        %     
        Font
                
    end
       
    properties(Access=private)
        UiLabel
        UiSpaceTop 
        UiSpaceBottom
    end
    
    methods
        function obj = label(labelStr,varargin)
            
            if ~exist('labelStr','var')
                labelStr = 'Sample text';
            end

            obj = obj@gui.widget(varargin{:});
            assert(~obj.Initialized && ~obj.Visible);
            
            color = obj.getParentUiColor();
            
            obj.UiHandle = gui.util.uiflowcontainer('Parent',obj.ParentUiHandle, ...
                'units', 'pixels', ...
                'BackgroundColor',color, ...
                'flowdirection', 'topdown', ...
                'DeleteFcn', @(h,e) delete(obj)); 
            
            obj.Visible = false; 
            
            obj.UiSpaceTop = uicontrol('Style','text', 'Parent',obj.UiHandle,...
                'units', 'pixels', ...
                'Visible', 'off', ...
                'BackgroundColor',color);
                
            obj.UiLabel = uicontrol( 'Style','Text','Parent',obj.UiHandle,...
                'BackgroundColor', color,...
                'units', 'pixels', ...                
                'position', [0 0 60 20],...
                'string', labelStr, ...
                'HorizontalAlignment', 'Left', ...
                'Fontweight', 'bold', ...
                'Fontangle', 'italic', ...
                'HandleVisibility', 'off');

            obj.UiSpaceBottom = uicontrol('Style','text', 'Parent',obj.UiHandle,...
                'units', 'pixels', ...
                'Visible', 'off', ...                
                'BackgroundColor',color);
            
            % default fontsize is 2 points greater than default
            set(obj.UiLabel, 'Fontsize', get(obj.UiLabel, 'Fontsize') + 1);

            % obj is the most derived class (since it is sealed)                                    
            obj.Initialized = true;
            obj.Visible = true;
        end
                
        function out = get.TopMargin(obj)
            lim = get(obj.UiSpaceTop, 'heightlimits');
            out = lim(1);
        end
        
        function set.TopMargin(obj, m)
            if ~(isnumeric(m) && isscalar(m) && isreal(m) && (m > 0))
                throwAsCaller(MException('label:TopMargin', 'TopMargin should be a number >= 0'));
            end
            set(obj.UiSpaceTop, 'heightlimits', [m m]);            
            obj.updateSize();
        end

        function out = get.BottomMargin(obj)
            lim = get(obj.UiSpaceBottom, 'heightlimits');
            out = lim(1);
        end
        
        function set.BottomMargin(obj, m)
            if ~(isnumeric(m) && isscalar(m) && isreal(m) && (m > 0))
                throwAsCaller(MException('label:TopMargin', 'TopMargin should be a number >= 0'));
            end            
            set(obj.UiSpaceBottom, 'heightlimits', [m m]);            
            obj.updateSize();            
        end
            
        function out = get.Value(obj)
            out = get(obj.UiLabel, 'string');
        end
        
        function set.Value(obj, val)
            if ~(ischar(val) || iscellstr(val))
                throwAsCaller(MException('label:Value', 'Value should be a string or a cell array of strings'));
            end                        
            set(obj.UiLabel, 'string', val);
            obj.updateSize();
        end
        
        function set.Alignment(obj,alignment)
            try
                set(obj.UiLabel,'HorizontalAlignment', alignment);
            catch %#ok<CTCH>
                throwAsCaller(MException('label:Alignment', 'Alignment should be ''left'', ''center'' or ''right'''));   
            end
        end

        function out = get.Alignment(obj)
            out = get(obj.UiLabel,'HorizontalAlignment');
        end        
        
        function set.Font(obj,f)
            fn = fieldnames(f);
            for i=1:length(fn)
                switch fn{i}
                    case {'size','angle','weight'}
                        try
                            set(obj.UiLabel, ['font' fn{i}], f.(fn{i}));
                        catch %#ok<CTCH>
                            throwAsCaller(MException('label:font', 'Invalid value for Font.%s', fn{i}));
                        end
                    otherwise
                        throwAsCaller(MException('label:font', 'Invalid field (valid fields are size, angle, and weight)'));
                end                    
            end
            obj.updateSize();
        end
        
        function f = get.Font(obj)            
            f.size = get(obj.UiLabel,'FontSize');
            f.angle = get(obj.UiLabel,'FontAngle');
            f.weight = get(obj.UiLabel,'Fontweight');
        end
        
    end
   

    methods(Access=protected)
        function initNotify(obj)
            set(obj.UiSpaceTop, 'heightlimits', [10 10]); % default top margin
            set(obj.UiSpaceBottom, 'heightlimits', [1 1]); % default bottom margin
            obj.updateSize();
        end        
    end
    
    methods(Access=private)
        
        function updateSize(obj)
            neededSize = get(obj.UiLabel, 'Extent'); % [0 0 width height]
            newWidth = neededSize(3) + 3; % allow some slop
            newHeight = obj.TopMargin + (neededSize(4)+3) + obj.BottomMargin;
            obj.Position = struct('width', newWidth, 'height', newHeight);
        end
 
    end
end

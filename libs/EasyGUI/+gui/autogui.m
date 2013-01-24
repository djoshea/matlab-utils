% gui.autogui
%    g = gui.autogui() creates a figure with a "gui area" and a
%    "plotting area".
%
%    g = gui.autogui(property1, value1, property2, value2,...)
%    initializes the autogui with the specified property
%    values.
%
%  * The GUI area: When a new widget is created, by default it
%    adds itself to the current autogui and is displayed in
%    the gui area. Widgets are added top to bottom, left to
%    right.
%     g.addPanel()  makes room for a new panel or column of widgets
%     g.PanelWidth  controls the width of the current panel
%     g.Location    controls the location of the gui area
%                   relative to the plotting area
%
%  * The plotting area: Normal drawing and axes commands (e.g.,
%    GCA, PLOT, SUBPLOT) can be used in the plotting area; no
%    special syntax is needed.
%
%  * User input: The autogui can monitor the widgets for user
%    input.
%     g.monitor(w1,w2,..)  monitors the specified list of widgets
%     g.waitForInput()     waits for user input in the monitored widgets
%     g.LastInput          returns the widget with most-recent input
%
%  Sample usage:
%    g = gui.autogui;
%    w1 = gui.numericmenu('Sampling rate (Hz)', [5000 8192 11025 22050 44100]);
%    w2 = gui.slider('Prefiltering', [0 1]);
%    g.addPanel;
%    w3 = gui.editnumber('Sinusoid frequency (Hz)');
%    w4 = gui.textmenu('Window', {'Hamming', 'Rectangular'});
%
%    subplot(211);
%    subplot(212);
%
%    while g.waitForInput()
%       disp(g.LastInput.Value);
%       subplot(211); plot(rand(1,100));
%       subplot(212); plot(randn(1,100));
%    end

%   Copyright 2009 The MathWorks, Inc.

classdef (Sealed) autogui < gui.container

    properties
        % Name
        %   A string indicating the name of the gui. This string
        %   is used as the name of the figure window.
        %
        %   Sample usage:
        %    g = gui.autogui;
        %    g.Name = 'Filter GUI';
        Name
    end
    
    properties(GetAccess=public, SetAccess=private)
        % Children
        %   A cell array of widgets in the gui. This property is
        %   read-only.
        Children
    end
        
    properties
        % PanelWidth
        %   The width (in pixels) of the current gui panel. 
        %
        %   Sample usage:
        %    g = gui.autogui;
        %    g.PanelWidth = 120; % make the current panel very narrow
        %    w1 = gui.editnumber('Enter a number');
        %    w2 = gui.slider('My slider');
        %    g.addPanel; % add a new panel
        %    g.PanelWidth = 250; % make the current panel very wide
        %    w3 = gui.slider('Another slider');
        PanelWidth = 200
        
        % Location
        %   A string indicating the location of the gui area relative
        %   to the axes. Possible values are:
        %     'left'  : The gui area is to the left of the axes
        %     'right' : The gui area is to the right of the axes
        %     'float' : Only the gui area is shown; the axes are not
        %               displayed. 
        % 
        %   Sample usage:
        %    g = gui.autogui;
        %    g.PanelWidth = 120; % make the current panel very narrow
        %    w1 = gui.editnumber('Enter a number');
        %    w2 = gui.slider('My slider');
        %    g.Location = 'right'; 
        %    g.Location = 'float';
        Location = 'left'

        % Fontsize
        %   The default fontsize to be used for new widgets in the gui (it
        %   will have no effect on previously added widgets).
        Fontsize 
    end
    
    properties(Dependent)
        % Visible
        %   A boolean indicating whether the gui figure window should be 
        %   visible or not. 
        %    true  => gui figure window is visible  (default)
        %    false => gui figure window is invisible or hidden.
        Visible

        % Position 
        %   The position of the gui figure window on the screen. Position
        %   is a struct with the following fields: 
        %     x, y  : the coordinates for the lower-left corner of the figure 
        %     width : the width of the figure window
        %     height: the height of the figure window
        %
        %   Sample usage:
        %      g = gui.autogui;
        %
        %      % Retrieving the position
        %      g.Position
        %      g.Position.height    
        % 
        %      % Modifying the position
        %      g.Position.height = 200; 
        %      g.Position = struct('width', 200, 'height', 300);
        %
        %      p = g.Position;
        %      p.width = 200;
        %      p.height = 300;
        %      g.Position = p;
        Position
        
        % Resizeable
        %   A boolean indicating whether the gui figure window can be
        %   resized using the mouse.
        %    true  => gui figure window can be resized using the mouse
        %            (default)
        %    false => gui figure window cannot be resized using the mouse.
        %             However, the Position property can still be used
        %             to change the gui figure window size.
        Resizeable
        
        % Exclusive
        %   A boolean indicating whether the gui figure window is 'modal'
        %   i.e., overrides all other windows and dialog boxes and forces
        %   the user to respond. 
        %    true  => gui figure window is Exclusive 
        %    false => gui figure window is not Exclusive (default).
        Exclusive 
        
        % ValueChangedFcn 
        %             
        %   ValueChangedFcn specifies an optional function handle. This
        %   function is invoked if the Value property changes in any widget
        %   in a set of widgets. The set of widgets may be specified by a
        %   prior call to MONITOR. By default, the set is all the widgets
        %   currently in the gui.
        %
        %   The ValueChangedFcn will be invoked  with one input argument
        %   (the handle to the widget). 
        %
        %   To disable ValueChangedFcn, set it to [].
        %
        %   Sample usage:
        %    myGui = gui.autogui;
        %    w1 = gui.slider('My slider', [1 100]);
        %    w2 = gui.textmenu('My menu', {'red', 'blue', 'green'});
        %    myGui.ValueChangedFcn = @(h) disp(h.Value);
        %    % now try changing the slider value
        %    myGui.ValueChangedFcn = []; % disable it
        %
        %    myGui.ValueChangedFcn = @myFunction; 
        %    
        %   Also see:
        %    <a href="matlab:help gui.autogui.monitor">monitor</a> (method)
        %    <a href="matlab:help gui.autogui.waitForInput">waitForInput</a> (method)                
        ValueChangedFcn        
    end
    
    properties(GetAccess=public, SetAccess=private)
        % LastInput
        %   A handle to a widget, used in conjunction with the
        %   waitForInput() method. When waitForInput() returns
        %   successfully, the LastInput property indicates the 
        %   widget with the most-recent input activity.
        % 
        %    Also see:
        %    <a href="matlab:help gui.autogui.ValueChangedFcn">ValueChangedFcn</a> (property)
        %    <a href="matlab:help gui.autogui.monitor">monitor</a> (method)
        %    <a href="matlab:help gui.autogui.waitForInput">waitForInput</a> (method)        
        LastInput
    end
    
    properties(Constant, GetAccess=private)
        DefaultPlotAreaWidth = 420
    end
    
    properties (Access=private)
        UiMainContainer
        UiPlotArea = []
        UiGuiArea = []
        UiGuiPanelGroup 
        UiCurrentGuiPanel 
        
        MinimumGuiPanelHeight = 1
            
        ChildList = struct('widget', {}, 'storedWidth',{}, 'storedHeight', {}, 'panel',{})
        CurrentPanelNum = 0      
        WidgetMonitor = []
        WidgetMonitorMode = 'auto'
    end
    
    methods        
        function obj = autogui(varargin)            
            if rem(nargin,2)==1
                throw(MException('autogui:InvalidParameter', ...
                    ['Parameters should property-value pairs, e.g.,\n' ...
                     'gui.autogui(''Fontsize'', 10, ''Visible'', false, ...)']));
            end            
            % need to start with visible == off to prevent flicker when
            % visibility is turned off later. 
            hFig = figure('visible', 'off');
            obj@gui.container(hFig);
            
            set(obj.UiHandle, 'defaultaxescreatefcn', @(h,e) axesCreated(obj, h));           
            
            % prevent reentrant callbacks (e.g. if the computation take a while 
            % and a slider button is kept pressed)            
            set(obj.UiHandle, 'defaultuicontrolinterruptible','off', ...
                              'defaultuicontrolbusyaction','cancel');

            % UiHandle
            %   UiMainContainer [uiflowcontainer] - contains guiarea & plotarea
            %      UiPlotArea [uipanel]
            %      UiGuiArea [uipanel]
            %          UiGuiPanelGroup [uiflowcontainer]
            %             UiCurrentGuiPanel [uiflowcontainer]
                        
            obj.Fontsize = 10; % default fontsize
            
            obj.UiMainContainer = gui.util.uiflowcontainer('parent', obj.UiHandle, ...
                                            'units', 'normalized', ...
                                            'position', [0 0 1 1], ...
                                            'backgroundcolor', obj.BackgroundColor, ...
                                            'flowdirection','lefttoright', ...
                                            'tag', 'autogui-maincontainer');

            obj.UiGuiArea = uipanel('parent', obj.UiMainContainer, ...
                                    'units', 'pixels', ...
                                    'backgroundcolor', obj.BackgroundColor, ...
                                    'tag', 'autogui-guiarea');

            set(obj.UiGuiArea, 'widthlimits', [1 1], ...
                               'heightlimits', [2 inf]);
                           
            obj.UiGuiPanelGroup = gui.util.uiflowcontainer('parent', obj.UiGuiArea, ...      
                                                  'units', 'pixels', ...
                                                  'backgroundcolor', obj.BackgroundColor, ...
                                                  'flowdirection','lefttoright', ...
                                                  'tag', 'autogui-guipanelgroup');
                       
            obj.addPanel();
            set(obj.UiGuiArea, 'HeightLimits', obj.MinimumGuiPanelHeight + [0 0]);  

            createPlotArea(obj, obj.Location, false);            
                        
            addlistener(obj, 'BackgroundColor', 'PostSet', ...
                @(src,e) updateBackgroundColor(obj));       
            
            try
                % apply the parameter list in two phases.
                % phase 1: stash the params in a struct (this avoids issues
                % like multiple occurrences of a param -- only the last
                % occurrence counts).                
                cnt = 1;
                tmpStruct = [];
                while cnt+1 <= numel(varargin)
                    param = varargin{cnt};
                    val = varargin{cnt+1}; 
                    tmpStruct.(param) = val;
                    cnt=cnt+2;
                end
                % ensure visibility by default, unless explicitly turned off
                if ~isfield(tmpStruct, 'Visible')
                    tmpStruct.Visible = true;
                end
                % phase 2: apply the struct params to the object                
                fn = fieldnames(tmpStruct).';
                for f=fn
                    obj.(f{1}) = tmpStruct.(f{1});
                end                
            catch ME
                delete(obj.UiHandle);
                throw(MException('autogui:InvalidParameter', ['Unable to create autogui\n' ME.message]));
            end
        end
                
        function delete(obj)
            % As widgets get deleted, obj.ChildWidgets can change under us
            % so use a temporary list for looping
            tempChildWidgets = obj.Children;            
            for i=1:numel(tempChildWidgets)
                removeChild(obj, tempChildWidgets{i});
            end
            % No need to delete obj.UiMainContainer, etc.; these will 
            % be cleaned up by the figure deletion.
        end
        
        function disp(obj)
            gui.util.showObjectInfo.properties(obj);
        end
    end 
    
    % get/set methods
    methods
        function set.Name(obj,str)            
            set(obj.UiHandle,'name',str);
        end
        
        function out = get.Name(obj)
            out = get(obj.UiHandle,'name');
        end
        
        function set.Visible(obj,makeVisible)
            if ~(isscalar(makeVisible) && (islogical(makeVisible) || isnumeric(makeVisible)))
                throw(MException('autogui:InvalidVisible', 'Visible should be true or false'));
            end
            if makeVisible
                set(obj.UiHandle, 'Visible', 'on');
            else
                set(obj.UiHandle, 'Visible', 'off');
            end            
        end
        
        function out = get.Visible(obj)
            out = strcmp(get(obj.UiHandle,'Visible'), 'on');
        end
        
        function out = get.Children(obj)
            out = {obj.ChildList.widget};
        end
        
        function set.PanelWidth(obj, requestedWidth)
            w = updatePanelWidth(obj, obj.PanelWidth, requestedWidth);
            if w ~= requestedWidth
                warning('autogui:PanelWidthAdjustment', ...
                    ['Some widgets cannot support width of %d pixels,\n' ...
                    'so the panel width is set to %d pixels'], ...
                    requestedWidth, w);
            end            
            set(obj.UiCurrentGuiPanel,  'widthlimits', [w w]);
            changeGuiAreaWidth(obj, w - obj.PanelWidth);
            refresh(obj.UiHandle);
            obj.PanelWidth = w;
        end
        
        
        function set.Location(obj, newLocation)
            str = [obj.Location '->' newLocation];
            switch str
                case {'left->left', 'right->right', 'float->float'}
                    % nothing to do
                case 'right->left'
                    set(obj.UiMainContainer, 'flowdirection', 'lefttoright');
                case 'left->right'
                    set(obj.UiMainContainer, 'flowdirection', 'righttoleft');
                case {'float->left', 'float->right'}
                    createPlotArea(obj, newLocation, true);
                case {'left->float', 'right->float'}
                     deletePlotArea(obj);
                otherwise
                    throw(MException('autogui:InvalidLocation', ...
                        'Location should be ''left'', ''right'' or ''float'''));
            end
            obj.Location = newLocation;
            refresh(obj.UiHandle);
        end
        
        function set.Position(obj, s)           
            pos = gui.util.uiposition.structToVec(s);         
            % pos is [x y w h]
            % Unspecified fields have a value of nan in pos.
            curpos = get(obj.UiHandle, 'position');
            indices = isnan(pos);
            pos(indices) = curpos(indices);
            set(obj.UiHandle,'position', pos);
        end
        
        function s = get.Position(obj)
            p = get(obj.UiHandle, 'position');
            s = struct('x', p(1), 'y', p(2), 'width', p(3), 'height', p(4));
        end

        function set.Resizeable(obj, makeResizeable)
            if makeResizeable
                str = 'on';
            else
                str = 'off';
            end
            set(obj.UiHandle, 'Resize', str);            
        end
        
        function out = get.Resizeable(obj)
            out = strcmp(get(obj.UiHandle,'Resize'),'on');            
        end
        
        function set.Exclusive(obj, makeExclusive)
            if makeExclusive
                str = 'modal';
            else
                str = 'normal';
            end
            set(obj.UiHandle, 'WindowStyle', str);                        
        end
        
        function out = get.Exclusive(obj)
            out = strcmp(get(obj.UiHandle, 'WindowStyle'), 'modal');
        end
        
        function set.Fontsize(obj, fsize)
            if isscalar(fsize) && isnumeric(fsize) && (fsize > 0)
                obj.Fontsize = fsize;
                set(obj.UiHandle, 'defaultuicontrolfontsize', fsize);
            else
                throw(MException('autogui:InvalidFontsize', 'Fontsize should be a positive number'));
            end
        end
        
        function set.ValueChangedFcn(obj, f)
            if isempty(obj.WidgetMonitor)
                if isempty(obj.Children)
                    throw(MException('autogui:InvalidParameter', ...
                        'This gui has no widgets to monitor!'));
                end
                updateMonitor(obj, obj.Children);
                obj.WidgetMonitorMode = 'auto';                
            end
            obj.WidgetMonitor.ValueChangedFcn = f;
        end
        
        function f = get.ValueChangedFcn(obj)
            if isempty(obj.WidgetMonitor)
                f = [];
            else
                f = obj.WidgetMonitor.ValueChangedFcn;
            end
        end
    end
    
    % public methods
    methods
        
        function addPanel(obj)
            % addPanel          gui.autogui method
            %
            %   obj.addPanel() adds a new vertical panel to the current gui.
            %     Any widgets that are subsequent added to the gui will be
            %     added to the new panel. The width of the current panel may be
            %     adjusted using the PanelWidth property.
            %
            %  Sample usage:
            %   g = gui.autogui;
            %   w1 = gui.edittext('My field 1');;
            %   w2 = gui.edittext('My field 2');
            %   g.addPanel();
            %   g.PanelWidth = 300;
            %   w3 = gui.edittext('My field 3');
            %   w4 = gui.edittext('My field 4');
            
            obj.UiCurrentGuiPanel = gui.util.uiflowcontainer('parent', obj.UiGuiPanelGroup, ...
                                                     'backgroundcolor', obj.BackgroundColor, ...
                                                     'flowdirection','topdown', ...
                                                     'tag', 'autogui-currentguipanel');
            obj.CurrentPanelNum = obj.CurrentPanelNum + 1;
            set(obj.UiCurrentGuiPanel, 'widthlimits', obj.PanelWidth + [0 0]);
            obj.changeGuiAreaWidth( obj.PanelWidth + 4 );     
            refresh(obj.UiHandle);
        end   
        
        
        function addChild(obj, child)
            % addChild         gui.autogui method
            %
            %   obj.addChild(w) adds the child widget w to the current gui.
            %
            %   There is usually no need to call this function directly; the
            %   child widgets automatically add themselves to the gui.

            % Note: child construction may not be complete when this function is
            % called
            assert(isa(child, 'gui.widget'));
            if ~isempty(obj.findChild(child))
                throwAsCaller(MException('autogui:InvalidAdd', 'Widget is already a child of the container'));
            end 
            obj.ChildList(end+1) = struct('widget', child, ...
                                          'storedWidth', nan, ...
                                          'storedHeight', nan, ...
                                          'panel', obj.CurrentPanelNum);
            
            child.setUiParent(obj, obj.UiCurrentGuiPanel);
            updateChildVisibility(obj, child);
            
            % listeners will be deleted automatically when child is destroyed            
            % Also, listeners have Recursive=false by default.
            addlistener(child, 'ObjectBeingDestroyed', @(h,e) removeChild(obj, h));
            addlistener(child, 'Visible', 'PostSet', @(src,e) updateChildVisibility(obj,e.AffectedObject));
            
            if ~isempty(obj.WidgetMonitor) && strcmp(obj.WidgetMonitorMode, 'auto')
                try
                    updateMonitor(obj, obj.Children);
                catch ME
                    warning('autogui:addChild', ['Unable to update monitor\n' ME.message]);
                end
            end
        end
        
        
        function removeChild(obj, child)      
            % removeChild        gui.autogui method
            %
            %   obj.removeChild(w) removes the child widget w to the current
            %     gui and deletes it.
            %
            %   There is usually no need to call this function directly. When a
            %   widget is deleted, it automatically removes itself from the
            %   gui.
            assert(isa(child, 'gui.widget'));
            index = obj.findChild(child);
            if isempty(index)
                throwAsCaller(MException('autogui:InvalidAdd', 'Widget is not a child of the container'));
            end 
                        
            if isvalid(child)
                % this will invoke removeChild via listener
                % and will also release all the associated listeners
                delete(child);
            else
                obj.ChildList(index) = [];
            end
        end
        
        
        function monitor(obj, varargin)
            % monitor          gui.autogui method
            %   Specify the set of widgets to be monitored by the
            %   waitForInput() and the ValueChangedFcn property
            %
            %   obj.monitor(w1, w2, ..., wn) specifies that the widgets w1, 
            %     w2, ... wn should be monitored.
            %
            %   obj.monitor(C) specifies that the widgets in the cell 
            %     array C should be monitored.
            %
            %   Sample usage:
            %    g = gui.autogui;
            %    w1 = gui.edittext('Your name');
            %    w2 = gui.slider('Age in years', [1 100]);
            %
            %    g.monitor(w1,w2); % monitor w1,w2
            %    g.monitor(w2);    % monitor only w2
            %    w3 = gui.editnumber('Employee ID');
            %    g.monitor(g.Children); % monitors w1,w2,w3
            %
            %    while g.waitForInput()
            %       disp(g.LastInput.Value);
            %    end
            %
            %    Also see:
            %    <a href="matlab:help gui.autogui.LastInput">LastInput</a> (property)
            %    <a href="matlab:help gui.autogui.ValueChangedFcn">ValueChangedFcn</a> (property)
            %    <a href="matlab:help gui.autogui.waitForInput">waitForInput</a> (method)
            
            % updateMonitor will throw if there is a problem
            updateMonitor(obj, varargin{:});
            obj.WidgetMonitorMode = 'manual';
        end
                
        
        function allOk = waitForInput(obj)
            % waitForInput            gui.autogui method
            %   Waits for any input in a set of widgets. The set of widgets
            %   may be specified by a prior call to MONITOR. By default,
            %   the set is all the widgets currently in the gui. 
            %
            %   allOk = obj.waitForInput() waits until there is an input (i.e., 
            %   until the Value property of a widget is modified).
            %
            %    allOk is true => there was an input, and the corresponding
            %       widget is given by the LastInput property.
            %    allOk is false => the gui was closed or deleted in the
            %       meantime. The LastInput property is undefined.
            %
            %   Sample usage:
            %    g = gui.autogui;
            %    w1 = gui.edittext('Enter your name');
            %    w2 = gui.slider('Age (in years)');
            %    while g.waitForInput()
            %       disp(g.LastInput.Value);
            %    end
            %
            %    Also see:
            %    <a href="matlab:help gui.autogui.LastInput">LastInput</a> (property)
            %    <a href="matlab:help gui.autogui.ValueChangedFcn">ValueChangedFcn</a> (property)
            %    <a href="matlab:help gui.autogui.monitor">monitor</a> (method)
            if isempty(obj.WidgetMonitor)
                if isempty(obj.Children)
                    throw(MException('autogui:InvalidParameter', ...
                        'This gui has no widgets to monitor!'));
                end                
                updateMonitor(obj, obj.Children);
                obj.WidgetMonitorMode = 'auto';                
            end
                        
            allOk = obj.WidgetMonitor.waitForInput();
            if allOk
                obj.LastInput = obj.WidgetMonitor.LastInput;
            end
            
            if ~allOk && isvalid(obj)
                obj.LastInput = [];
            end
        end
    end
    
    % Methods used in callbacks
    methods(Hidden)
        % used for testing
        function out = getDebugInfo(obj)
            out.numPanels = obj.CurrentPanelNum;
        end
        
        function axesCreated(obj, hAxes)
            set(hAxes, 'parent', obj.UiPlotArea);
        end
        
        function updateBackgroundColor(obj)
            col = obj.BackgroundColor;
            set([obj.UiMainContainer obj.UiPlotArea obj.UiGuiArea obj.UiGuiPanelGroup], 'BackgroundColor', col);
            set(get(obj.UiGuiPanelGroup, 'Children'), 'BackgroundColor', col);
        end
        
        function updateChildVisibility(obj, child)
            if ~child.Visible
                return;
            end
            
            index = obj.findChild(child);
            % assert is not JIT-ed
            % assert(~isempty(index));

            if isnan(obj.ChildList(index).storedWidth)
                % widget just added to container, 
                % try to accomodate it to the panel                
                child.setPositionWidth(obj.PanelWidth);
                % if widget can't match obj.PanelWidth, adjust panel instead
                if child.getPositionWidth() > obj.PanelWidth
                    obj.PanelWidth = child.getPositionWidth();
                end
                obj.ChildList(index).storedWidth = child.getPositionWidth();
                obj.ChildList(index).storedHeight = child.getPositionHeight();
                addlistener(child, 'PositionChanged', @(h,e) updateChildVisibility(obj,h));  
                
                obj.updatePanelHeight(child, index, true);
            else                                
                obj.checkChildWidth(child, index);
                obj.updatePanelHeight(child, index, false);
            end            
        end
        
    end
       
   %% private helper methods    
   methods (Access=private)

       % creates a WidgetMonitor (overwrites one if it already exists).
       % In case of error, WidgetMonitor is set to [] and mode to 'auto'
        function updateMonitor(obj, varargin)
            if isempty(obj.WidgetMonitor)
                 oldValueChangedFcn = [];
            else
                oldValueChangedFcn = obj.WidgetMonitor.ValueChangedFcn;
                delete(obj.WidgetMonitor);
            end
            
            try
                obj.WidgetMonitor = gui.monitor(varargin{:});
                obj.WidgetMonitor.Timeout = inf;
                obj.WidgetMonitor.ValueChangedFcn = oldValueChangedFcn;
            catch ME
                obj.WidgetMonitor = [];
                obj.WidgetMonitorMode = 'auto';
                throwAsCaller(MException('autogui:monitor', ['Unable to monitor widgets\n' ME.message]));
            end
            obj.LastInput = [];
        end
       
        function indices = findChildrenInPanel(obj, panelNum)
           if ~exist('panelNum', 'var'), 
               panelNum = obj.CurrentPanelNum; 
           end
           % assert is not JIT-ed
           % assert((panelNum > 0) && panelNum <= obj.CurrentPanelNum);
           indices = find([obj.ChildList.panel] == panelNum);
        end
        
       function index = findChild(obj, child)           
           n = numel(obj.ChildList);
           index = [];
           for i=1:n
               if (child == obj.ChildList(i).widget)
                   index = i; break;
               end
           end
       end
       
        % does not update obj.Location        
        function createPlotArea(obj, newLocation, doResizeFigure)            
            % add the plotarea  and expand the size of the figure to match
            % assert is not JIT-ed
            assert(isempty(obj.UiPlotArea));
            obj.UiPlotArea = gui.util.uicontainer('parent', obj.UiMainContainer, ...
                'units', 'pixels', ...
                'backgroundcolor', obj.BackgroundColor, ...
                'tag', 'autogui-plotarea');
            drawnow;
            
            if doResizeFigure
                figpos = get(obj.UiHandle,'position');
                figpos(3) = figpos(3) + obj.DefaultPlotAreaWidth;
                set(obj.UiHandle,'position',figpos);
            end
            
            set(obj.UiHandle, 'menubar', 'figure', ...
                'HandleVisibility', 'on', ...
                'resize', 'on', ...
                'units', 'pixels', ...
                'numbertitle', 'on');
            
            if strcmp(newLocation, 'right')
                set(obj.UiMainContainer, 'flowdirection', 'righttoleft');
            elseif strcmp(newLocation, 'left')
                set(obj.UiMainContainer, 'flowdirection', 'lefttoright');
            end            
            
            axes('parent',obj.UiHandle);
        end
        
       
        % does not update obj.Location
        function deletePlotArea(obj)        
            % delete the plotArea & resize the figure to be just
            % the size of hGuiAreaFrame
            assert(~isempty(obj.UiPlotArea));
            delete(obj.UiPlotArea);
            obj.UiPlotArea = [];
            drawnow;                        
            
            figpos = get(obj.UiHandle, 'position');
            guiwidth = get(obj.UiGuiArea, 'widthlimits');
            guiheight = get(obj.UiGuiArea, 'heightlimits');
            newpos = [figpos(1:2) guiwidth(1)+5 guiheight(1)+5];
            set(obj.UiHandle, 'Position', newpos);
            
            set(obj.UiHandle, 'menubar', 'none', ...
                'HandleVisibility', 'on', ...
                'resize', 'off', ...
                'units', 'pixels', ...
                'numbertitle', 'off');
            
        end       
       
       
        function changeGuiAreaWidth(obj, delta)                
            figpos = get(obj.UiHandle, 'position');
            guiwidth = get(obj.UiGuiArea, 'widthlimits');
            
            guiwidth = guiwidth + delta;            
            if strcmp(obj.Location, 'float')
                figpos(3) = guiwidth(1);                
            else
                figpos(3) = figpos(3) + delta;
            end
            set(obj.UiGuiArea, 'widthlimits', guiwidth);
            set(obj.UiHandle, 'position', figpos);
        end
        
        % check if child's width has changed. if yes, see if
        % panel width needs to be updated. 
        function checkChildWidth(obj, child, index)
            % child is assumed to be visible            
            % and widget already in the container
            % assert is not JIT-ed
            % assert(~isnan(obj.ChildList(index).storedWidth));            
            newwidth = child.getPositionWidth();
            if newwidth > obj.PanelWidth
                % try to stretch the panel
                obj.PanelWidth = newwidth;
            else % newwidth <= obj.PanelWidth
                % nothing to do
                obj.ChildList(index).storedWidth = newwidth;
            end
        end
        
        
        function updatePanelHeight(obj, child, index, forceRecompute)
            if obj.ChildList(index).panel ~= obj.CurrentPanelNum               
                return;  % we don't handle recomputes for old panels
            end            
            newHeight = child.getPositionHeight();
            if (newHeight == obj.ChildList(index).storedHeight) && ~forceRecompute                
                return; % nothing to change
            end
            
            % recalculate height of current panel
            obj.ChildList(index).storedHeight = newHeight;
            indices = obj.findChildrenInPanel();
            totalHeight = sum([obj.ChildList(indices).storedHeight]) + (4*numel(indices));            
            totalHeight = totalHeight + 10; 

            % check if we need to grow the GuiArea
            if totalHeight > obj.MinimumGuiPanelHeight                                             
                set(obj.UiGuiArea, 'HeightLimits', totalHeight + [0 0]);
                obj.MinimumGuiPanelHeight = totalHeight;     
                
                % check if we need to grow the figure as well
                pos = obj.Position;
                if totalHeight > pos.height
                    % grow downward
                    increment = totalHeight - pos.height;
                    obj.Position = struct('y', pos.y-increment, 'height', totalHeight);
                end

                refresh(obj.UiHandle);
            end
        end
        
        
       % The main invariant: the panel should be at least as wide
       % as the widest child.
       function finalwidth = updatePanelWidth(obj, oldwidth, newwidth)
           % note: newwidth hasn't been committed to obj.PanelWidth yet
           indices = obj.findChildrenInPanel();
           if (newwidth >= oldwidth) || isempty(indices) 
               % no extra work to be done.  
               finalwidth = newwidth;
           else 
               % shrink child widgets if possible
               tmpWidthList = zeros(size(obj.ChildList));
               for i=indices
                   child = obj.ChildList(i).widget;
                   if obj.ChildList(i).storedWidth > newwidth                       
                       child.setPositionWidth(newwidth);
                       newChildWidth = child.getPositionWidth();
                       obj.ChildList(i).storedWidth = newChildWidth;
                       tmpWidthList(i) = newChildWidth;
                   end                   
               end
               % some child widgets may not be able to shrink as requested
               % ensure that panel is wider than these
               maxWidgetWidth = max(tmpWidthList);
               finalwidth = max(maxWidgetWidth, newwidth);
           end

       end
        
   end
   
   
   methods(Static)
        function obj = getCurrentInstance()
            % getCurrentInstance
            %
            %  obj = gui.autogui.getCurrentInstance() returns the
            %  most-recent instance of gui.autogui. If there is
            %  no such instance, obj is [].
            
            % fig is the list of figures (the current figure is always
            % first in the list). Note that findall works even if
            % HandleVisibility is 'off'
            fig = findall(0,  '-depth', 1, 'type', 'figure', 'tag', 'EasyGUIContainer');                        
            obj = [];                        
            for i=1:length(fig)
                if isa(get(fig(i),'userdata') , 'gui.autogui')
                    obj = get(fig(i),'userdata');
                    break;
                end                
            end            
        end 
        
    end

    
end



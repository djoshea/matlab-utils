% gui.widget
%
%   An abstract class for a generic widget. Widgets are "sealed" upon
%   construction, i.e., once created the  parent can't be changed. 

%   Copyright 2009 The MathWorks, Inc.

classdef widget < handle
 
  
    % Default: GetAccess=public, SetAccess=public
    % In the default DISP(), properties are shown in the
    % order they are listed here.
    
    properties (Dependent)
        %
        % Position - The position of widget relative to its parent.
        %
        %   Position is a struct with the following fields
        %     x, y  : the coordinates for the lower-left corner of the widget
        %     width : the width of the widget
        %     height: the height of the widget
        %
        %   Sample usage:
        %      w = gui.slider;
        %
        %      % Retrieving the position
        %      w.Position
        %      w.Position.height    
        % 
        %      % Modifying the position
        %      w.Position.height = 200; 
        %      w.Position = struct('width', 200, 'height', 300);
        %
        %      p = w.Position;
        %      p.width = 200;
        %      p.height = 300;
        %      w.Position = p;
        %
        %   Note: if the parent of the widget does automatic layout (i.e., automatically 
        %   determines the best positioning of the widget), then some of the above
        %   fields may not work as expected.
        Position 
    end
    
    properties (SetObservable, Dependent)
        % Visible - Specifies whether the widget should be shown or not.
        %
        %   Visible is a boolean property (true/false).     
        %    true => widget is displayed on screen (default)
        %    false => widget is not displayed on screen.
        %
        %   Sample usage:
        %    w = gui.slider;
        %    w.Visible = false;
        Visible        
    end

    properties (SetObservable)
        
        % ValueChangedFcn - Function to be called whenever Value is updated.
        % 
        %   ValueChangedFcn specifies an optional function handle. Whenever
        %   the Value property is updated, this function will be invoked
        %   with one input argument (the handle to the widget). 
        %   To disable ValueChangedFcn, set it to [].
        % 
        %   Sample usage:
        %    w = gui.slider;
        %    w.ValueChangedFcn = @(x) disp(w.Value);
        %    % now try changing the slider value
        %    w.ValueChangedFcn = []; % disable it                
        %    w.ValueChangedFcn = @myFunction;
        ValueChangedFcn = []   
    end

    properties(GetAccess=public, SetAccess=protected)
        % 
        % Parent - The parent object of this widget [read only]
        % 
        %   Parent is the handle of this widget's parent (which is 
        %   an object of class gui.widget or gui.container). This
        %   property is set when this widget is created and cannot
        %   be modified.
        %
        Parent = []
    end
    
    properties(Dependent,Abstract) 
       Value 
    end        
 
    properties(Access=protected)
        UiHandle = []         
        ParentUiHandle = []
        Initialized = false
    end
    
    properties (Access=private)
      ValueChangedFcnListener = []
      PostInitializationFunctions = {}
      UiHandlePos 
      ParentFigure
    end
    
    events
        ValueChanged
        PositionChanged
    end
     
    % Contructor & destructor
    methods
        % Constructor help for widget class 1
        function obj = widget(parent, uiParent)                        
            % Constructor help for widget class 2
            % parent can be another widget or a container            
            if ~exist('parent', 'var')
                obj.Parent = gui.autogui.getCurrentInstance();
                if isempty(obj.Parent)
                    obj.Parent = gui.autogui(); % create a new instance
                end                
            elseif isa(parent, 'gui.container') && isvalid(parent)
                obj.Parent = parent;
            elseif isa(parent, 'gui.widget') && isvalid(parent) 
                obj.Parent = parent;
            else
                throwAsCaller(MException('widget:InvalidParent', 'Parent should be a valid container or another widget'));
            end

            if exist('uiParent', 'var') 
                obj.ParentUiHandle = uiParent;
            else                 
                obj.ParentUiHandle = obj.Parent.UiHandle;
            end

            % Parent.addChild() is called when Initialized is set to true
        end
                        
        function set.Initialized(obj, val)
            % ensure that Initialize is only set once (to true)
            if obj.Initialized || ~val
                throw(MException('widget:Initialize', 'Internal error'));
            end
            if ~strcmp(get(obj.UiHandle, 'units'), 'pixels')
                throw(MException('widget:Initialize', 'Internal error -- non-pixel units'));
            end
            obj.Initialized = true;
            if ismethod(obj.Parent, 'addChild')
                obj.Parent.addChild(obj);
            end
            initNotify(obj);
        end
        
        function delete(obj)
            % when an object is deleted, delete() is called on all of its
            % component objects as well. So if the Parent is deleted,
            % this widget will get deleted as well.
            if ishandle(obj.UiHandle) && strcmp(get(obj.UiHandle, 'BeingDeleted'), 'off')
                delete(obj.UiHandle);
            end
            if ~isempty(obj.ValueChangedFcnListener) && isvalid(obj.ValueChangedFcnListener)
                delete(obj.ValueChangedFcnListener);
            end
        end

    end
    
    %Properties
    methods(Hidden)
        % this can only be called by obj.Parent
        function setUiParent(obj, parent, h)
            if obj.Parent ~= parent
                throw(MException('widget:InvalidUiParent', 'Invalid UI parent!'));
            end
            % When new or old parent is a uiflowcontainer
            % the actual position of the child can change. So
            % maintain the current position via an explicit set.
            pos = obj.Position; 
            obj.ParentUiHandle = h;
            obj.setPositionWidth(pos.width);
            obj.setPositionHeight(pos.height);
        end             
    end    
    
    methods        

        function disp(obj)
            gui.util.showObjectInfo.properties(obj);
        end
        
        function set.UiHandle(obj, h)
            assert(get(h,'parent') == obj.ParentUiHandle);
            obj.UiHandle = h;
            obj.UiHandlePos = gui.util.uiposition(h);
            obj.ParentFigure = ancestor(h, 'figure');
        end
        
        function set.ParentUiHandle(obj, h)
            if ishandle(h)
                obj.ParentUiHandle = h;
                if ishandle(obj.UiHandle)
                    set(obj.UiHandle, 'parent', h);
                    obj.UiHandlePos = gui.util.uiposition(obj.UiHandle);
                    obj.ParentFigure = ancestor(h, 'figure');
                end                
            else
                throw(MException('widget:InvalidUiHandle', 'Invalid HG Handle for parent'));
            end            
        end
        
        function set.ValueChangedFcn(obj, f)
            if isa(f, 'function_handle')
                obj.ValueChangedFcn = f;
                if isempty(obj.ValueChangedFcnListener) 
                    obj.ValueChangedFcnListener = event.listener(obj, 'ValueChanged', @(src,eventdata) f(src));
                    % listener cannot trigger a ValueChanged event
                    obj.ValueChangedFcnListener.Recursive = false;
                else 
                    obj.ValueChangedFcnListener.Callback = @(src,eventdata) f(src);
                end
            elseif isempty(f)
                obj.ValueChangedFcn = f;
                if ~isempty(obj.ValueChangedFcnListener)
                    delete(obj.ValueChangedFcnListener);
                end
                obj.ValueChangedFcnListener = [];
            else
                throw(MException('widget:InvalidValueChangedFcn', 'ValueChangedFcn should be a function handle'));
            end
        end

        
        function set.Position(obj, s)                       
            pos = gui.util.uiposition.structToVec(s);         
            % pos is [x y w h]
            % Unspecified fields in s have a value of nan in pos.             
            obj.UiHandlePos = obj.UiHandlePos.setVector(pos);
            obj.postPositionChange(pos);
            notify(obj, 'PositionChanged');
            refresh(obj.ParentFigure);
        end
        
        function setPositionWidth(obj, newWidth)
            if (newWidth == obj.UiHandlePos.Width)
                return;
            end
            obj.UiHandlePos.Width = newWidth;
            obj.postPositionChange([nan nan newWidth nan]);
            notify(obj, 'PositionChanged');
            refresh(obj.ParentFigure);
        end
        
        function setPositionHeight(obj, newHeight)
            if (newHeight == obj.UiHandlePos.Height)
                return;
            end
            obj.UiHandlePos.Height = newHeight;            
            obj.postPositionChange([nan nan nan newHeight]);
            notify(obj, 'PositionChanged');
            refresh(obj.ParentFigure);
        end
        
        function s = get.Position(obj)
            p = obj.UiHandlePos.getVector();           
            s = struct('x', p(1), 'y', p(2), 'width', p(3), 'height', p(4));
        end
        
        function val = getPositionWidth(obj)
            val = obj.UiHandlePos.Width;
        end   
        
        function val = getPositionHeight(obj)
            val = obj.UiHandlePos.Height;
        end
        
        function set.Visible(obj, makeVisible)
            % Note: uicontrols are created with 'visible'='on' by default.
            % When they are parented to uicontainers with visible='off',
            % they are briefly visible, leading  to a flicker.             
            
            if isempty(obj.UiHandle)
                throw(MException('widget:InvalidVisible', 'Empty UiHandle'));
            end
            if makeVisible
                set(obj.UiHandle, 'Visible', 'on');
            else
                set(obj.UiHandle, 'Visible', 'off');
            end
        end
        
        function out = get.Visible(obj)
            if isempty(obj.UiHandle)
                out = false;
            else
                out = strcmp(get(obj.UiHandle,'visible'),'on');
            end
        end

        
    end

    methods(Access=protected)
                
        % called after position is changed
        % pos is [x y w h] the new position.
        % nan's indicate default (unmodified) values
        function postPositionChange(obj, pos)   %#ok<INUSD>
            % no-op
        end

        function color = getParentUiColor(obj)
            if isprop(obj.ParentUiHandle, 'color')
                color = get(obj.ParentUiHandle, 'Color');
            else
                color = get(obj.ParentUiHandle, 'BackgroundColor');
            end
        end       
    end    

    methods(Access=protected,Abstract)
        % called when the object has completed initialization
        % and has been added to the parent
        initNotify(obj)
                
    end
               
end
    


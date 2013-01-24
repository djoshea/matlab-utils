% gui.group
%    A widget that can contain other widgets. 
%    THIS IS A PRELIMINARY IMPLEMENTATION AND HAS NOT BEEN 
%    TESTED WITH THE REST OF THE WIDGET CLASSES.
%
%    G = gui.group() creates a widget that can contain other widgets. G is
%    added to the current autogui (if there is no current autogui, one is
%    created).
%
%    G = gui.group(ORIENT) sets the property Orientation to ORIENT. This
%    specifies how the widgets in this group are to be laid out. By
%    default, ORIENT is 'lefttoright'
%
%    Sample usage:
%     grp = gui.group;
%     b1 = gui.pushbutton('Submit', grp);
%     b2 = gui.pushbutton('Cancel', grp);
%     grp.ValueChangedFcn = @(g) disp(g.Value.Label);
% 

%   Copyright 2009 The MathWorks, Inc.

classdef (Sealed) group < gui.borderedwidget
    
    properties(Dependent)
        % Value 
        %   The widget in this gui.group that was most recently active
        %   (or [] if no widget has been active).
        Value    
    end

    properties(GetAccess=public, SetAccess=private)
        % Children
        %   A cell array of widgets (all the widgets that are currently in
        %   the gui.group object).
        Children
    end
    
   properties(Dependent,GetAccess=public, SetAccess=private)
        % Orientation should be one of: 'lefttoright', 'topdown', 'righttoleft',
        % 'bottomup'        
        Orientation
   end
    
    properties(Access=private)
        ChildWidgets = {}
        UiFlowContainer
        LastActiveWidget = []        
    end
                    
    methods
        function obj = group(orientation, varargin)

            if ~exist('orientation','var')
                orientation = 'lefttoright';
            end

            obj = obj@gui.borderedwidget(varargin{:});
            assert(~obj.Initialized && ~obj.Visible);
            
            % save the user-specified orientation in userdata for 
            % use in initNotify
            obj.UiFlowContainer = gui.util.uiflowcontainer('parent', obj.UiHandle, ...
                'units', 'normalized', ...
                'position', [0 0 1 1], ...
                'userdata', orientation);
            
            obj.Initialized = true;
            obj.Visible = true;
        end
                            
        function out = get.Orientation(obj)
            out = get(obj.UiFlowContainer, 'FlowDirection');
        end
        
        function set.Orientation(obj, val)
            if ischar(val) && ...
                    ~isempty(strmatch(val, {'lefttoright', 'topdown', 'righttoleft', 'bottomup'}))
                set(obj.UiFlowContainer, 'FlowDirection', val);
            else
                throwAsCaller(MException('group:InvalidOrientation', ...
                        'Orientation should be one of: ''lefttoright'', ''topdown'', ''righttoleft'', ''bottomup'''));      
            end
        end
           
        function set.Value(obj, val) 
            if isnumeric(val) && isempty(val)
                obj.LastActiveWidget = [];
            else
                throwAsCaller(MException('group:InvalidValue', 'Value can only be set to []'));
            end
        end
        
        function out = get.Value(obj) 
            out = obj.LastActiveWidget;
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
        
        function out = get.Children(obj)
            out = obj.ChildWidgets;
        end

        function addChild(obj, child)
           assert(isa(child,'gui.widget'));
            if ~isempty(findChildIndex(obj, child))
                throw(MException('group:addChild', 'Widget is already a child of the container'));
            end 
            
            obj.ChildWidgets{end+1} = child;
            child.setUiParent(obj, obj.UiFlowContainer);
            addlistener(child, 'ObjectBeingDestroyed', @(h,e) removeChild(obj, h));
            addlistener(child, 'ValueChanged', @(h,e) childValueChanged(obj,h));
            addlistener(child, 'PositionChanged', @(src,e) updateChildVisibility(obj,src));
            addlistener(child, 'Visible', 'PostSet', @(src,e) updateChildVisibility(obj,e.AffectedObject));            
        end
        
        function removeChild(obj, child)
            index = obj.findChildIndex(child);
            if isempty(index) 
                throw(MException('group:removeChild', 'Widget is not a child of the container'));
            end
            
            if isvalid(child)
                delete(child); % this will invoke removeChild via listener
                % and will also release all the associated listeners
            else
                obj.ChildWidgets(index) = [];
            end            
        end
        
    end

    methods(Hidden)
        function childValueChanged(obj,child)
            obj.LastActiveWidget = child;
            % propagate the event 
            notify(obj, 'ValueChanged');
        end

        % To do:
        % when top-down is used, then we need to recalculate the height of
        % the group (possibly, get positions of all the children and
        % finding the bounding rectangle).
        
        function updateChildVisibility(obj, child)
            if child.Visible
                numChildren = numel(obj.ChildWidgets);
                sizes = zeros(numChildren,2);                
                for i=1:numChildren
                    sizes(i,:) = [obj.ChildWidgets{i}.getPositionWidth() ...
                                  obj.ChildWidgets{i}.getPositionHeight()];
                end
                switch obj.Orientation
                    case {'lefttoright', 'righttoleft'}
                        newwidth = sum(sizes(:,1)) + (numChildren-1)*4 + 5;
                        newheight = max(sizes(:,2)) + 8;
                    case {'topdown', 'bottomup'}
                        newwidth = max(sizes(:,1)) + 8;        
                        newheight = sum(sizes(:,2)) + (numChildren*4);
                    otherwise
                        throwAsCaller('group:group', 'Internal error -- invalid orientation');
                end
                oldwidth = obj.getPositionWidth();
                oldheight= obj.getPositionHeight();
                if (newwidth > oldwidth) || (newheight > oldheight)
                    newwidth = max(oldwidth, newwidth);
                    newheight = max(oldheight, newheight);
                    obj.Position = struct('width', newwidth, 'height', newheight);                    
                end
            end
        end        
    end
    
    methods(Access=protected)
        function initNotify(obj)
            initNotify@gui.borderedwidget(obj);
            obj.Orientation = get(obj.UiFlowContainer, 'userdata');
            set(obj.UiFlowContainer, 'userdata', []);
            obj.Position = struct('width', 200, 'height', 40);            
        end
    end
    
    methods (Access=private)

        function index = findChildIndex(obj, child)
           if isempty(obj.ChildWidgets)
               index = [];
           else
               index = find(cellfun(@(w) child == w, obj.ChildWidgets));
           end
        end        
       
    end
    
end

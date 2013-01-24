% gui.manualgui
%
%  A simple widget container that does not do any automatic layout. It can
%  be used as a parent for widgets (like gui.slider and gui.textmenu) but 
%  their positions within the container have to be set explicitly.
%
%  Sample usage:
%    g = gui.manualgui;
%    w1 = gui.slider('My slider', [0 1], g);
%    w1.Position = struct('x', 50, 'y', 50, 'width', 120);
%    w2 = gui.editnumber('Enter a number', g);
%    w2.Position = struct('x', 200, 'y', 50);

%   Copyright 2009 The MathWorks, Inc.

classdef manualgui < gui.container
        
    properties(GetAccess=public, SetAccess=private)
        % Children
        %   A cell array of widgets in the gui. This property is
        %   read-only.        
        Children
    end
    
    properties(Access=private)
        ChildWidgets = {}
    end
    
    methods
        function obj = manualgui()
            h = figure(...
                'Name', 'gui.manualgui', ...
                'BackingStore'      , 'off', ...
                'DockControls'      , 'off', ...
                'NumberTitle'       , 'off', ...
                'MenuBar'           , 'none', ...
                'Resize'            , 'on', ...
                'Visible'           , 'on', ...
                'WindowStyle'       , 'normal');
            
            obj@gui.container(h);      
            
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
                throw(MException('manualgui:addChild', 'Widget is already a child of the container'));
            end 
            
            obj.ChildWidgets{end+1} = child;
            child.setUiParent(obj, obj.UiHandle);
            addlistener(child, 'ObjectBeingDestroyed', @(h,e) removeChild(obj, h));
        end

        function removeChild(obj, child)
            index = obj.findChildIndex(child);
            if isempty(index) 
                throw(MException('manualgui:removeChild', 'Widget is not a child of the container'));
            end
            
            if isvalid(child)
                delete(child); % this will invoke removeChild via listener
                % and will also release all the associated listeners
            else
                obj.ChildWidgets(index) = [];
            end            
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

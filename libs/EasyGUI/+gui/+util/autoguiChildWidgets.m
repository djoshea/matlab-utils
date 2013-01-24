% autoguiChildWidgets
%
%  A helper class for gui.autogui

%   Copyright 2009 The MathWorks, Inc.

classdef autoguiChildWidgets < handle
   
    properties(Access=private)
        ChildWidgets = []
        ChildWidgetWidths
    end
   
    properties(GetAccess=public, SetAccess=private)
        CurrentPanelNum = 0
    end

    methods        
        function delete(obj)
            assert(isempty(obj.ChildWidgets) && isempty(obj.ChildInfo));
        end
        
        function out = getChildList(obj)
            out = obj.ChildWidgets;
        end
        
        function incrPanelNum(obj)
            obj.CurrentPanelNum = obj.CurrentPanelNum+1;
        end
                
        function add(obj, child, panelnum)
            assert(isa(child, 'gui.widget'));
            if ~isempty(findChildIndex(obj, child))
                throwAsCaller(MException('autogui:InvalidAdd', 'Widget is already a child of the container'));
            end 
            obj.ChildWidgets{end+1} = child;
            obj.ChildInfo(end+1) = struct('width', nan, 'panel', panelnum);
        end
        
        function remove(obj, child)
            index = obj.findChildIndex(child);
            if isempty(index) 
                throwAsCaller(MException('autogui:InvalidRemove', 'Widget is not a child of the container'));
            end            
            obj.ChildWidgets(index) = [];
            obj.ChildInfo(index) = [];
        end
        
        function out = ischild(obj,widget)
            out = ~isempty(obj.findChildIndex(widget));
        end
        
        function out = childrenInPanel(obj, panelNum)
           if ~exist('panelNum', 'var'), 
               panelNum = obj.CurrentPanelNum; 
           end
           assert((panelNum > 0) && panelNum <= obj.CurrentPanelNum);
           out = obj.ChildWidgets([obj.ChildInfo.panel] == panelNum);
        end
    end
    
    methods(Access=private)
       function index = findChildIndex(obj, child)
           if isempty(obj.ChildWidgets)
               index = [];
           else
               index = find(cellfun(@(w) child == w, obj.ChildWidgets));
           end
       end               
    end
    
end
   
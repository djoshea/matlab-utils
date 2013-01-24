% gui.container
%   An abstract class for collections of widgets. Child widgets can be
%   added to a container after creation of the container. 

%   Copyright 2009 The MathWorks, Inc.

classdef container < handle
    properties (GetAccess=public, SetAccess=private)
        % UiHandle 
        %   The HG handle of the gui (typically, a figure window). 
        %   This property is read-only.
        UiHandle
    end

    properties(Access=public, Dependent, SetObservable)
        % BackgroundColor
        %   A string or vector indcating the background color of the gui. 
        %   This background color may be adopted by the widgets that are
        %   added to the gui as well. Possible values can be:
        %
        %     * System-defined color specifiers like 'r' (for red) and 'k'
        %       (for black). See HELP PLOT for a full list.
        %
        %     * A three-element vector, [r g b], indicating the proportion
        %       of red, green and blue saturation. For example:
        %             [0 0 0] indicates black, 
        %             [1 1 1] indicates white, 
        %             [1 0 0] indicates red, etc.
        BackgroundColor
    end

    properties(GetAccess=public, SetAccess=private, Abstract)
        Children
    end
    
    methods
        function obj = container(uihandle)
            
            if ~exist('uihandle', 'var')                
                obj.UiHandle = figure();
            elseif ishandle(uihandle)  &&  strcmp(get(uihandle, 'tag'), 'EasyGUIContainer')
                % return the existing instance
                obj = get(uihandle, 'userdata');
                return;
            elseif ishandle(uihandle) && strmatch(get(uihandle,'type'), ...
                     {'figure', 'uipanel', 'uicontainer', 'uiflowcontainer', 'uigridcontainer'})
                obj.UiHandle = uihandle;
            else
                throw(MException('container:InvalidHandle', 'Invalid HG handle'));
            end

            % Backgroundcolor is the same as used by GUIDE
            set(obj.UiHandle, 'units', 'pixels', ...
                    'tag', 'EasyGUIContainer', ...
                    'color', [0.8314    0.8157    0.7843], ...
                    'userdata', obj, ...
                    'DeleteFcn', @(h,e) delete(obj));
        end
        
        function delete(obj)
            if ishandle(obj.UiHandle) && strcmp(get(obj.UiHandle, 'BeingDeleted'), 'off')
                delete(obj.UiHandle);
            end            
        end        
    end

    % Get/Set
    methods
        
        function set.BackgroundColor(obj, col)
            set(obj.UiHandle, 'Color', col);
        end
        
        function out = get.BackgroundColor(obj)
            out = get(obj.UiHandle, 'Color');
        end
    end

    methods(Abstract)
        % called to add a new child widget to this container
        % This function would be called from within the widget constructor.
        % implementation should check whether a to-be-added
        % child has already been added.
        addChild(obj, childWidget)

        % a child widget can't be reparented, but it can be 
        % destroyed.  
        removeChild(obj, childWidget)
    end
    
end

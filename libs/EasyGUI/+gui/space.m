% gui.space
%    A widget to introduce vertical and horizontal blank space
%
%    W = gui.space creates a widget for introducing blank space,
%    and adds it to the current autogui (if there is no
%    current autogui, one is created). The Position property can 
%    be used adjust the size of the space.
%
%    W = gui.space(G) creates the widget and adds it to gui container G. 
%
%  Sample usage:
%     g = gui.autogui;
%    w1 = gui.slider('My slider');
%    w2 = gui.space;
%    w3 = gui.edittext('Enter a string');
%    w2.Position.height = 100; % insert vertical space
%    w2.Position.width = 250; % stretch horizontal space

%   Copyright 2009 The MathWorks, Inc.

classdef (Sealed) space < gui.widget

    properties (Dependent)
        % Value 
        %   The space widget does not have a value. Use the Position 
        %   property to set the horizontal and vertical space.
        %
        %  Sample usage:
        %     g = gui.autogui;
        %    w1 = gui.slider('My slider');
        %    w2 = gui.space;
        %    w3 = gui.edittext('Enter a string');
        %    w2.Position.height = 100; % insert vertical space
        %    w2.Position.width = 250; % stretch horizontal space        
        Value 
    end
               
    methods
        function obj = space(varargin)
            
            obj = obj@gui.widget(varargin{:});
            assert(~obj.Initialized && ~obj.Visible);
            
            color = obj.getParentUiColor();
            
            obj.UiHandle = gui.util.uicontainer('Parent',obj.ParentUiHandle, ...
                'units', 'pixels', ...
                'BackgroundColor',color, ...
                'DeleteFcn', @(h,e) delete(obj)); 
            
            obj.Visible = false; 
                        
            % obj is the most derived class (since it is sealed)                                    
            obj.Initialized = true;
            obj.Visible = true;
        end
                            
        function out = get.Value(obj) %#ok<INUSD>
            out = [];
        end
        
        function set.Value(obj, val) %#ok<INUSD>
        end
        
        
    end
   

    methods(Access=protected)
        function initNotify(obj)
            obj.Position = struct('width', 20, 'height', 20);
        end        
    end
    
end

% gui.borderedwidget
%   An abstract class for widgets with a border.

%   Copyright 2009 The MathWorks, Inc.

classdef borderedwidget < gui.widget 
    
    properties(Dependent)
        BorderType
        Title
        TitlePosition
        TitleFontsize
        BackgroundColor
    end

    methods
        function obj = borderedwidget(varargin)

            obj = obj@gui.widget(varargin{:});

            color = obj.getParentUiColor();

            obj.UiHandle = uipanel('parent', obj.ParentUiHandle, ...
                                   'units', 'pixels', ...
                                   'backgroundcolor', color, ...
                                   'visible', 'off', ...
                                   'DeleteFcn', @(h,e) delete(obj));            
        end
        
    end
   
    % Property access
    methods 
        
        function out = get.BorderType(obj)
            out = get(obj.UiHandle, 'BorderType');
        end
        
        function set.BorderType(obj, bt)
            try
                set(obj.UiHandle, 'BorderType', bt);
            catch %#ok<CTCH>
                values = '[ none | etchedin | etchedout | beveledin | beveledout | line ]';
                throw(MException('borderedWidget:BorderType', ['BorderType should be one of:\n' values]));
            end
        end
        
        function out = get.Title(obj)
            out = get(obj.UiHandle, 'Title');
        end   
        
        function set.Title(obj, s)
            set(obj.UiHandle, 'Title', s);
        end
        
        function out = get.TitlePosition(obj)
            out = get(obj.UiHandle, 'TitlePosition');
        end
                
        function set.TitlePosition(obj, s)
            try
                set(obj.UiHandle, s);
            catch  %#ok<CTCH>
                values = '[ lefttop | centertop | righttop | leftbottom | centerbottom | rightbottom ]';
                throw(MException('borderedWidget:TitlePosition', ['TitlePosition should be one of:\n' values]));                
            end
        end
        
        function out = get.TitleFontsize(obj)
            out = get(obj.UiHandle, 'Fontsize');
        end   
        
        function set.TitleFontsize(obj, sz)
            set(obj.UiHandle, 'Fontsize', sz);
        end

        function out = get.BackgroundColor(obj)
            out = get(obj.UiHandle, 'BackgroundColor');
        end   
        
        function set.BackgroundColor(obj, c)
            set(obj.UiHandle, 'BackgroundColor', c);
        end
                
    end

    
    methods(Access=protected)
        function initNotify(obj) %#ok<INUSD>
            % nothing to do
        end
    end
    
end

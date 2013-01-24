% uiposition
%  A helper class for gui.autogui and gui.widget 

%   Copyright 2009 The MathWorks, Inc.

classdef uiposition
    
    properties(Dependent)
        X
        Y
        Width
        Height
    end
        
    properties(Access=private)
        UiHandle        
        InFlowContainer        
        CachedPositionVec
    end
    
    methods
        function obj = uiposition(uihandle)
            if ~ishandle(uihandle)
                throw(MException('positionx:error', 'Bad uihandle'));
            end
            obj.UiHandle = uihandle;
            obj.InFlowContainer = strcmp(get(get(uihandle, 'parent'),'type'), 'uiflowcontainer');
            obj = updateCachedPosition(obj);
        end
        
        function out = get.X(obj)
           out = obj.CachedPositionVec(1); 
        end

        function out = get.Y(obj)
           out = obj.CachedPositionVec(2); 
        end
                
        function obj = set.Width(obj, newWidth)
            pos = obj.CachedPositionVec;
            pos(3) = newWidth;
            if obj.InFlowContainer
                set(obj.UiHandle,'widthlimits', pos([3 3]));
            else
                set(obj.UiHandle,'position',pos);
            end
            obj.CachedPositionVec = pos;
        end
        
        function out = get.Width(obj)
            out = obj.CachedPositionVec(3);
        end

        function obj = set.Height(obj, newHeight)
            pos = obj.CachedPositionVec;
            pos(4) = newHeight;
            if obj.InFlowContainer
                set(obj.UiHandle,'heightlimits', pos([4 4]));
            else
                set(obj.UiHandle,'position',pos);
            end
            obj.CachedPositionVec = pos;
        end
        
        function out = get.Height(obj)
            out = obj.CachedPositionVec(4);
        end
        
        function out = getVector(obj)
            out = obj.CachedPositionVec;
        end
                    
        
        % assume s is already validated
        function obj = setStruct(obj, s)
            if obj.InFlowContainer
                % x and y coordinates don't matter
                if ~isnan(s.width)
                    set(obj.UiHandle, 'WidthLimits', s.width([1 1]));
                    obj.CachedPositionVec(3) = s.width;
                end
                if ~isnan(s.height)
                    set(obj.UiHandle, 'HeightLimits', s.height([1 1]));
                    obj.CachedPositionVec(4) = s.height;
                end
            else
                pos = [s.x s.y s.width s.height];
                indices = isnan(pos);
                pos(indices) = obj.CachedPositionVec(indices);
                set(obj.UiHandle, 'position', pos);
                obj.CachedPositionVec = pos;
            end            
        end
        
        function obj = setVector(obj,pos)
            if obj.InFlowContainer
                % x and y coordinates don't matter
                if ~isnan(pos(3))
                    set(obj.UiHandle, 'WidthLimits', pos([3 3]));
                    obj.CachedPositionVec(3) = pos(3);
                end
                if ~isnan(pos(4))
                    set(obj.UiHandle, 'HeightLimits', pos([4 4]));
                    obj.CachedPositionVec(4) = pos(4);
                end
            else
                indices = isnan(pos);
                pos(indices) = obj.CachedPositionVec(indices);
                set(obj.UiHandle, 'position', pos);
                obj.CachedPositionVec = pos;
            end                
        end

        function obj = updateCachedPosition(obj)
            if obj.InFlowContainer
                pos = [1 1 ...
                    max(get(obj.UiHandle, 'WidthLimits')) ...
                    max(get(obj.UiHandle, 'HeightLimits'))];
            else
                pos = get(obj.UiHandle, 'position');
            end
            obj.CachedPositionVec = pos;
        end
        
    end
    
    methods(Static)
        
        function setSizeInFlow(uihandle, sz)
            if ~isnan(sz(1))
                set(uihandle,'widthlimits',  sz([1 1]));
            end
            if ~isnan(sz(2))
                set(uihandle,'heightlimits', sz([2 2]));
            end
        end       

        function out = getHeightInFlow(uihandle)            
            hlim = get(uihandle,'heightlimits');
            out = hlim(1);
        end
                
        function pos = structToVec(s)
            pos = [nan nan nan nan];
            if ~isstruct(s)
                throw(MException('position:set', ...
                    'Position should be a struct with fields ''x'', ''y'', ''width'', or ''height'''));
            end
            % if there are no fields in the struct, pos will return with all
            % nan fields            
            isValid = true(1,4);
            fldnames = fieldnames(s);
            for i=1:numel(fldnames)
                switch fldnames{i}
                    case 'x', 
                        isValid(1) = isScalarNumber(s.x);
                        if isValid(1), pos(1) = s.x; end
                    case 'y',                         
                        isValid(2) = isScalarNumber(s.y);
                        if isValid(2), pos(2) = s.y; end
                    case 'width'
                        isValid(3) = isScalarNumber(s.width);
                        if isValid(3), pos(3) = s.width; end
                    case 'height'
                        isValid(4) = isScalarNumber(s.height);
                        if isValid(4), pos(4) = s.height; end
                    otherwise
                        throw(MException('position:set', ...
                            'Valid fields are ''x'', ''y'', ''width'', and ''height'''));                        
                end                
            end
            
            if ~all(isValid)
                throw(MException('position:set', ...
                    'x, y, width and height should be integers'));
            end                
        end        
        
    end
end


function out = isScalarNumber(val)
out = isnumeric(val) && isscalar(val) && isreal(val);
end

classdef DynamicAnnotation < handle
% This class is an abstract parent class for dynamic plot axis annotations
% that exist within the data axis (not actually annotations) but
% automatically reposition / redraw themselves when the plot is panned, 
% zoomed, or rotated

    properties(SetAccess=protected);
        ax
        positionListener
        xLimListener
        yLimListener
    end
    
    methods(Abstract)
        onUpdate(da, type, varargin)
    end
    
    methods
        function da = DynamicAnnotation(ax)
            if nargin < 1
                ax = gca;
            end
            
            da.ax = ax;
            da.install();
            da.updateCallback('init');
        end
        
        function flag=isMultipleCall(da)
          flag = false; 
          % Get the stack
          s = dbstack();
          if numel(s) <= 2
            % Stack too short for a multiple call
            return;
          end

          % How many calls to the calling function are in the stack?
          names = {s(:).name};
          TF = strcmp(s(2).name,names);
          count = sum(TF);
          if count>1
            % More than 1
            flag = true; 
          end
        end

        % install in the axis user data and setup callbacks
        function install(da)
            ax = da.ax;
            
            % store da in UserData
            da.installUserDataField(class(da), da);
            
            set(zoom(ax),'ActionPostCallback',@(varargin) da.updateCallback('zoom', varargin{:}));
            set(pan(get(ax, 'Parent')),'ActionPostCallback',@(varargin) da.updateCallback('pan', varargin{:}));
            set(get(ax, 'Parent'),'ResizeFcn',@(varargin) da.updateCallback('resize', varargin{:}));
        
            hax = handle(ax);
            hprop = findprop(hax,'Position');
            da.positionListener = handle.listener(hax,hprop,'PropertyPostSet',@(varargin) da.updateCallback(ax, 'pan', varargin{:}));
            
            hprop = findprop(hax, 'XLim');
            da.xLimListener = handle.listener(hax,hprop,'PropertyPostSet',@(varargin) da.updateCallback(ax, 'pan', varargin{:}));
            
            hprop = findprop(hax, 'YLim');
            da.yLimListener = handle.listener(hax,hprop,'PropertyPostSet',@(varargin) da.updateCallback(ax, 'pan', varargin{:}));
            
        end
        
        function update(da)
            da.updateCallback('manual');
        end
                
        function data = retrieveUserDataField(da, field)
            ud = get(da.ax, 'UserData');
            if isstruct(ud) && isfield(ud, field)
                data = ud.(field);
            else
                data = [];
            end
        end

        function installUserDataField(da, field, data)
            ud = get(da.ax, 'UserData');
            if isstruct(ud) 
                if isfield(ud, field) && ~isempty(ud.(field)) && ~ishandle(ud.(field))
                    delete(ud.(field));
                end
                    
                ud.(field) = data;
            else
                ud = [];
                ud.(field) = data;
            end
            set(da.ax, 'UserData', ud);
        end
        
        function updateCallback(da, type, varargin)
            if da.isMultipleCall(); return; end
            da.onUpdate(type, varargin{:});
        end
    end
end

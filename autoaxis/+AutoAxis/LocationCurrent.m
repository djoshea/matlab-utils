classdef LocationCurrent < handle & matlab.mixin.Copyable
     % Specifed properties inferred from properties beginning with v*
     % or NaN if not specified
     
    properties(SetAccess=protected)
        h % graphics handle this refers to
        type % string type of graphics object
        isDynamic % should this position be re-queried on each update (false means trust the last position)
        top
        bottom
        left
        right
    end
    
    properties(Dependent)
        vcenter
        height
        hcenter
        width
    end
    
    methods
        function v = get.vcenter(loc)
            v = (loc.top + loc.bottom) / 2;
        end
        
        function v = get.height(loc)
            v = loc.top - loc.bottom;
        end
        
        function v = get.hcenter(loc)
            v = (loc.left + loc.right) / 2;
        end
        
        function v = get.width(loc)
            v = loc.right - loc.left;
        end
    end
        
    methods(Static)
        function loc = buildForHandle(h, varargin)
            loc = AutoAxis.LocationCurrent();
            loc.h = h;
            if ~ishandle(h)
                return;
            end
            loc.type = get(h, 'Type');
            
            loc.isDynamic = strcmp(loc.type, 'axes');

            loc.queryPosition(varargin{:});
        end
        
        function pos = getAggregateValue(infoVec, posType, xReverse, yReverse)
            % given a set of LocationSpec instances, determine the value of field that holds across all 
            % of the objects. E.g. if field is 'left', returns the minimum value of info.left for all info in infoVec
            % posType is AutoAxis.PositionType

            import AutoAxis.PositionType;
            
            field = posType.getDirectField();
            if numel(infoVec) == 1
                pos = infoVec.(field);
                return;
            end

            % compute derivative positions recursively
            pos = [];
            switch posType
                case PositionType.VCenter
                    top = LocationInfo.getAggregateValue(infoVec, PositionType.Top);
                    bottom = LocationInfo.getAggregateValue(infoVec, PositionType.Bottom);
                    pos = (top+bottom)/2;

                case PositionType.Height
                    top = LocationInfo.getAggregateValue(infoVec, PositionType.Top);
                    bottom = LocationInfo.getAggregateValue(infoVec, PositionType.Bottom);
                    pos = top - bottom;

                case PositionType.HCenter
                    left = LocationInfo.getAggregateValue(infoVec, PositionType.Left);
                    right = LocationInfo.getAggregateValue(infoVec, PositionType.Right);
                    pos = (left+right)/2;

                case PositionType.Width
                    left = LocationInfo.getAggregateValue(infoVec, PositionType.Left);
                    right = LocationInfo.getAggregateValue(infoVec, PositionType.Right);
                    pos = right - left;
            end
            if ~isempty(pos), return; end

            % find max or min over all values
            posVec = arrayfun(@(info) info.(field), infoVec);
            switch posType
                case PositionType.Top
                    if yReverse
                        pos = nanmin(posVec);
                    else
                        pos = nanmax(posVec);
                    end
                case PositionType.Bottom
                    if yReverse
                        pos = nanmax(posVec);
                    else
                        pos = nanmin(posVec);
                    end
                case PositionType.Left
                    if xReverse
                        pos = nanmax(posVec);
                    else
                        pos = nanmin(posVec);
                    end
                case PositionType.Right
                    if xReverse
                        pos = nanmin(posVec);
                    else
                        pos = nanmax(posVec);
                    end
            end
        end
    end
    
    methods
        function queryPosition(loc, xDataToPoints, yDataToPoints, xReverse, yReverse)
            % xReverse is true if x axis is reversed, yReverse if y
            % reversed
            
            switch loc.type
                case 'line'
                    marker = get(loc.h, 'Marker');
                    markerSize =get(loc.h, 'MarkerSize');
                    if(strcmp(marker, '.'))
                        markerSize = markerSize / 2;
                    end
                    if strcmp(marker, 'none')
                        markerSize = 0;
                    end
                    
                    markerSizeX = markerSize / xDataToPoints;
                    markerSizeY = markerSize / yDataToPoints;
                    xdata = get(loc.h, 'XData');
                    ydata = get(loc.h, 'YData');
                    %npts = numel(xdata);

                    loc.top = nanmax(ydata) + markerSizeY/2;
                    loc.bottom = nanmin(ydata) - markerSizeY/2;
                    loc.left = nanmin(xdata) - markerSizeX/2;
                    loc.right = nanmax(xdata) + markerSizeX/2;
                    
                    if xReverse
                        tmp = loc.left;
                        loc.left = loc.right;
                        loc.right = tmp;
                    end
                    if yReverse
                        tmp = loc.top;
                        loc.top = loc.bottom;
                        loc.bottom = tmp;
                    end

                case 'text'
                    set(loc.h, 'Units', 'data');
                    ext = get(loc.h, 'Extent'); % [left,bottom,width,height]
                    if yReverse
                        loc.bottom = ext(2);
                        loc.top = ext(2) - ext(4);
                    else
                        loc.top = ext(2) + ext(4);
                        loc.bottom = ext(2);
                    end
                    if xReverse
                        loc.left = ext(1);
                        loc.right = ext(1) - ext(3);
                    else
                        loc.left = ext(1);
                        loc.right = ext(1) + ext(3);
                    end

                case 'axes'
                    % return the limits of the axis...i.e. the coordinates
                    % of the inner position of the axis in data units
                    lim = axis(loc.h);
                    loc.top = lim(4);
                    loc.bottom = lim(3);
                    loc.left = lim(1);
                    loc.right = lim(2);
                    
                    if xReverse
                        tmp = loc.left;
                        loc.left = loc.right;
                        loc.right = tmp;
                    end
                    if yReverse
                        tmp = loc.top;
                        loc.top = loc.bottom;
                        loc.bottom = tmp;
                    end
                    
                case 'rectangle'
                    posv = get(loc.h, 'Position');
                    if yReverse
                        loc.top = posv(2);
                        loc.bottom = posv(2) - posv(4);
                    else
                        loc.bottom = posv(2);
                        loc.top = posv(2) - posv(4);
                    end
                    
                    if xReverse
                        loc.right = posv(1);
                        loc.left = posv(1) - posv(3);
                    else
                        loc.left = posv(1);
                        loc.right = posv(1) - posv(3);
                    end
            end
            
            
        end

        function setPosition(loc, posType, value, xDataToPoints, yDataToPoints, xReverse, yReverse)
            import AutoAxis.*;
            h = loc.h; %#ok<*PROP>
            type = get(h, 'Type');

            switch type
                case 'line'
                    marker = get(h, 'Marker');
                    markerSize =get(h, 'MarkerSize');
                    if(strcmp(marker, '.'))
                        markerSize = markerSize / 2;
                    end
                    if strcmp(marker, 'none')
                        markerSize = 0;
                    end
                    markerSizeX = markerSize / xDataToPoints;
                    markerSizeY = markerSize / yDataToPoints;

                    xdata = get(h, 'XData');
                    ydata = get(h, 'YData');

                    % rescale the appropriate data points from their
                    % current values to scale linearly onto the new values
                    % but only along the dimension to be resized
                    switch posType
                        case PositionType.Top
                            if yReverse
                                ydata = ydata - nanmin(ydata) + value + markerSizeY/2;
                            else
                                ydata = ydata - nanmax(ydata) + value - markerSizeY/2;
                            end

                        case PositionType.Bottom
                            if yReverse
                                ydata = ydata - nanmin(ydata) + value + markerSizeY/2;
                            else
                                ydata = ydata - nanmax(ydata) + value - markerSizeY/2;
                            end

                        case PositionType.VCenter
                            lo = nanmin(ydata); hi = nanmax(ydata);
                            ydata = (ydata - (hi+lo)/2) + value;

                        case PositionType.Height
                            lo = nanmin(ydata); hi = nanmax(ydata);
                            if hi - lo < eps, return, end
                            ydata = (ydata - lo) / (hi - lo + markerSizeY) * value + lo;

                        case PositionType.Left
                            if xReverse
                                xdata = xdata - nanmax(xdata) + value + markerSizeX/2;
                            else
                                xdata = xdata - nanmin(xdata) + value - markerSizeX/2;
                            end
                            
                        case PositionType.Right
                            if xReverse
                                xdata = xdata - nanmin(xdata) + value - markerSizeX/2;
                            else
                                xdata = xdata - nanmax(xdata) + value + markerSizeX/2;
                            end
                            
                        case PositionType.HCenter
                            lo = nanmin(xdata); hi = nanmax(xdata);
                            xdata = (xdata - (hi+lo)/2) + value;

                        case PositionType.Width
                            lo = nanmin(xdata); hi = nanmax(xdata);
                            if hi - lo < eps, return, end
                            xdata = (xdata - lo) / (hi - lo + markerSizeX) * value + lo;
                    end

                    set(h, 'XData', xdata, 'YData', ydata);
                    
                    % update position
                    if xReverse
                        loc.right = nanmin(xdata);
                        loc.left = nanmax(xdata);
                    else
                        loc.left = nanmin(xdata);
                        loc.right = nanmax(xdata);
                    end
                    
                    if yReverse
                        loc.bottom = nanmax(ydata);
                        loc.top = nanmin(ydata);
                    else
                        loc.top = nanmax(ydata);
                        loc.bottom = nanmin(ydata);
                    end
                    
                case 'text'
                    set(h, 'Units', 'data');
                    p = get(h, 'Position'); % [x y z] - ancor depends on alignment
                    ext = get(h, 'Extent'); % [left,bottom,width,height]
                    yoff = ext(2) - p(2);
                    xoff = ext(1) - p(1);
                    %m = get(h, 'Margin'); % margin in pixels
                    %mx = m / ax.xDataToPixels;
                    %my = m / ax.yDataToPixels;

                    switch posType
                        case PositionType.Top
                            if yReverse
                                p(2) = value + ext(4) - yoff;
                            else
                                p(2) = value - ext(4) - yoff;
                            end
                            
                        case PositionType.Bottom
                            p(2) = value - yoff;
                            
                        case PositionType.VCenter
                            if yReverse
                                p(2) = value + ext(4)/2 - yoff;
                            else
                                p(2) = value - ext(4)/2 - yoff;
                            end

                        case PositionType.Right
                            if xReverse
                                p(1) = value + ext(3) - xoff;
                            else
                                p(1) = value - ext(3) - xoff;
                            end
                            
                        case PositionType.Left
                            p(1) = value - xoff;
                            
                        case PositionType.HCenter
                            if xReverse
                                p(1) = value + ext(3)/2 - xoff;
                            else
                                p(1) = value - ext(3)/2 - xoff;
                            end
                    end

                    set(h, 'Position', p);
                    
                    % update position
                    ext = get(h, 'Extent'); % [left,bottom,width,height]
                    if yReverse
                        loc.bottom = ext(2);
                        loc.top = ext(2) - ext(4);
                    else
                        loc.bottom = ext(2);
                        loc.top = ext(2) + ext(4);
                    end
                    if xReverse
                        loc.left = ext(1);
                        loc.right = ext(1) - ext(3);
                    else
                        loc.left = ext(1);
                        loc.right = ext(1) + ext(3);
                    end
                    
                case 'rectangle'
                    p = get(h, 'Position'); % [left, bottom, width, height]

                    switch posType
                        case PositionType.Top
                            if yReverse
                                p(2) = value;
                            else
                                p(2) = value - p(4);
                            end
                        case PositionType.Bottom
                            if yReverse
                                p(2) = value - p(4);
                            else
                                p(2) = value;
                            end
                        case PositionType.VCenter
                            p(2) = value - p(4)/2;
                            
                        case PositionType.Height
                            p(4) = value;
                            
                        case PositionType.Right
                            if xReverse
                                p(1) = value;
                            else
                                p(1) = value - p(3);
                            end
                        case PositionType.Left
                            if xReverse
                                p(1) = value - p(3);
                            else
                                p(1) = value;
                            end
                        case PositionType.HCenter
                            p(1) = value - p(3)/2;
                            
                        case PositionType.Width
                            p(3) = value;
                            
                    end

                    set(h, 'Position', p);
                    if yReverse
                        loc.top = p(2);
                        loc.bottom = p(2) + p(4);
                    else
                        loc.top = p(2) + p(4);
                        loc.bottom = p(2);
                    end
                    
                    if xReverse
                        loc.left = p(1) + p(3);
                        loc.right = p(1);
                    else
                        loc.left = p(1);
                        loc.right = p(1) + p(3);
                    end
            end
        end
    end   
end

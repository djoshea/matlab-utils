classdef ScaleBarAnnotation < DynamicAnnotation
    properties(SetAccess=protected)
        hHorz
        hLabel
        hVert
        vLabel
    end
    
    properties
        location = 'se'; % one of ne, nw, se, sw
        lineWidth = 2;
        color = 'k';
        fontSize
        
        xVisible = true; % t / f
        xLength
        xLengthMode = 'auto';
        xUnits = '';
        
        yVisible = true;
        yLength
        yLengthMode = 'auto'
        yUnits = '';
    end
    
    methods
        function da = ScaleBarAnnotation(varargin)
            da = da@DynamicAnnotation(varargin{:});
        end
        
        function onUpdate(da, type, varargin)
            ax = da.ax;
            axis(ax, 'off');
            currHold = ishold(ax);
            currUnits = get(ax, 'Units');
            
            if isempty(da.hHorz) || ~ishandle(da.hHorz)
                hold(ax, 'on');
                da.hHorz = rectangle('Position', [0 0 eps eps]);
                set(da.hHorz, 'XLimInclude', 'off', 'YLimInclude', 'off', 'FaceColor', da.color, 'EdgeColor', 'none');
            end

            if isempty(da.hVert) || ~ishandle(da.hVert)
                hold(ax, 'on');
                da.hVert = rectangle('Position', [0 0 eps eps]);
                set(da.hVert, 'XLimInclude', 'off', 'YLimInclude', 'off', 'FaceColor', da.color, 'EdgeColor', 'none');
            end
            
            if isempty(da.hLabel) || ~ishandle(da.hLabel)
                hold(ax, 'on');
                da.hLabel = text(0, 0, '');
                set(da.hLabel, 'Color', da.color);
            end
            
            if isempty(da.vLabel) || ~ishandle(da.vLabel)
                hold(ax, 'on');
                da.vLabel = text(0, 0, '');
                set(da.vLabel, 'Color', da.color);
            end
            
            xl = get(ax, 'XLim');
            yl = get(ax, 'YLim');
            
            xRange = range(xl);
            yRange = range(yl);
            
            set(gca, 'Units', 'pixels');
            pos = get(gca, 'Position');
            pxWidth = pos(3);
            pxHeight = pos(4);
            xToPxFactor =  pxWidth / xRange;
            yToPxFactor =  pxHeight / yRange;
            xLineWidthData = da.lineWidth / yToPxFactor; % in pixels
            yLineWidthData = da.lineWidth / xToPxFactor;
            x1px = 1 / xToPxFactor;
            y1px = 1 / yToPxFactor;
            
            set(gca, 'Units', currUnits);
            
            if strcmp(da.xLengthMode, 'auto')
                xLength = median(diff(get(ax, 'XTick')));
            else
                xLength = da.xLength;
            end
            
            if strcmp(da.yLengthMode, 'auto');
                yLength = median(diff(get(ax, 'YTick')));
            else
                yLength = da.yLength;
            end
                
            % compute line locations
            switch(da.location)
                case 'se'
                    % pos = [x y width height]`
                    hpos = [xl(2)-xLength-x1px, yl(1)+y1px, xLength, xLineWidthData];
                    vpos = [xl(2)-yLineWidthData-x1px, yl(1)+y1px, yLineWidthData, yLength];
                    
                    hTextPad = '';
                    hTextPos = [xl(2)-xLength, yl(1)+xLineWidthData+2*y1px];
                    hhAlign = 'Left';
                    hvAlign = 'Bottom';
                    
                    vTextPad = '';
                    vTextPos = [xl(2)-xLineWidthData-2*x1px, yl(1)+yLength];
                    vhAlign = 'Right';
                    vvAlign = 'Top'; 
            end
            
            if(isempty(da.xUnits))
                xUnits = '';
            else
                xUnits = [' ' da.xUnits];
            end
            if(isempty(da.yUnits))
                yUnits = '';
            else
                yUnits = [' ' da.yUnits];
            end
            
            hString = sprintf('%g%s%s', xLength, xUnits, hTextPad);
            vString = sprintf('%g%s%s', yLength, yUnits, vTextPad);
            
            if(isempty(da.fontSize))
                fontSize = get(ax, 'FontSize');
            else
                fontSize = da.fontSize;
            end
                 
            if(da.xVisible)
                set(da.hHorz, 'Position', hpos, 'Visible', 'on', 'FaceColor', da.color);  
                set(da.hLabel, 'String', hString, 'Position', [hTextPos 0], ...
                    'HorizontalAlign', hhAlign, 'VerticalAlign', hvAlign, ...
                    'FontSize', fontSize, 'Color', da.color, 'Visible', 'on');
            else
                set(da.hHorz, 'Visible', 'off');
                set(da.hLabel, 'Visible', 'off');
            end
            
            if(da.yVisible)
                set(da.hVert, 'Position', vpos, 'Visible', 'on', 'FaceColor', da.color);
                set(da.vLabel, 'String', vString, 'Position', [vTextPos 0], ...
                    'HorizontalAlign', vhAlign, 'VerticalAlign', vvAlign, ...
                    'FontSize', fontSize, 'Color', da.color, 'Visible', 'on');
            else
                set(da.hVert, 'Visible', 'off');
                set(da.vLabel, 'Visible', 'off');
            end
            
            % restore old settings
            if currHold
                hold(ax, 'on');
            else
                hold(ax, 'off');
            end
            %set(ax, 'Units', currUnits);
        end
    end
    
    methods % Auto-update on set
        function set.location(da, v)
            da.location = v;
            da.update();
        end
        
        function set.lineWidth(da, v)
            da.lineWidth = v;
            da.update();
        end
        
        function set.color(da, v)
            da.color = v;
            da.update();
        end
        
        function set.fontSize(da, v)
            da.fontSize = v;
            da.update();
        end
        
        function set.xLength(da, v)
            da.xLength = v;
            da.xLengthMode = 'manual';
            da.update();
        end
        
        function set.yLength(da, v)
            da.yLength = v;
            da.yLengthMode = 'manual';
            da.update();
        end
        
        function set.xUnits(da, v)
            da.xUnits = v;
            da.update();
        end
        
        function set.yUnits(da, v)
            da.yUnits = v;
            da.update();
        end
    end
    
    methods(Static)
        function s = demo()
            hfig = figure();
            t = linspace(0, 8*pi, 1000);
            v = cos(t);
            plot(t, v, 'r-');
            xlim([0 8*pi]);
            
            s = ScaleBarAnnotation(gca);
            s.xUnits = 'ms';
            s.yUnits = 'uV';
            s.update();
        end
    end
end
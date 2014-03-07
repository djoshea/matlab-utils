classdef AutoAxis < handle
    
    properties
        axisInset = [2.2 2.2 1 2]; % [left bottom right top] inset around axes from outer position
        axisMargin = [0.2 0.2 0.2 0.2]; % [left bottom right top] margin between axes and label
    
        tickColor
        tickLength = 0.2; % cm
        tickLineWidth
        tickFontColor
        tickFontSize
        tickLabelOffset = 0.1; % cm
        
        labelFontSize
        labelFontColor
        labelOffset = 0; % cm
        
        titleFontSize
        titleFontColor
        
        scaleBarThickness = 0.2; % cm
        xUnits = '';
        yUnits = '';
        
        axisTickLength % cm
        
        debug = false;
    end
    
    properties(SetAccess=protected)
        axh
        anchorInfo % array of AutoAxisAnchorInfo objects
        locMap % map handle -> AutoAxisLocationInfo instance
        
        % handles of objects sitting below x axis but above x axis label
        hBelowX = []
        
        % handles of objects sitting left of y axis but right of y axis label
        hLeftY = []
        
        % handles of objects sitting right of y axis
        hRightY = []
        
        % these hold on to specific special objects that have been added
        % to the plot
        autoAxisX
        autoAxisY
        autoScaleBarX
        autoScaleBarY
        hTitle
        hXLabel
        hYLabel
        
        lastXLim
        lastYLim
    end

    properties(SetAccess=protected)
        xDataToUnits
        yDataToUnits
        
        xDataToPoints
        yDataToPoints
        
        xDataToPixels
        yDataToPixels
    end
    
    methods
        function ax = AutoAxis(axh)
            if nargin < 1 || isempty(axh)
                axh = gca;
            end
            
            ax = AutoAxis.createOrRecoverInstance(ax, axh);
        end
    end
    
    methods(Static)
        function ax = createOrRecoverInstance(ax, axh)
            % if an instance is stored in this axis' UserData.autoAxis
            % then return the existing instance, otherwise create a new one
            % and install it
            
            ud = get(axh, 'UserData');
            if isempty(ud) || ~isstruct(ud) || ~isfield(ud, 'autoAxis') || isempty(ud.autoAxis)
                ax.initializeNewInstance(axh);
                if ~isstruct(ud)
                    ud = struct('autoAxis', ax);
                else
                    ud.autoAxis = ax;
                end
                set(axh, 'UserData', ud);
            else
                % return the existing instance
                ax = ud.autoAxis;
            end
        end
    end
    
    methods    
        function initializeNewInstance(ax, axh)
            ax.axh = axh;
            
            %ax.hMap = containers.Map('KeyType', 'char', 'ValueType', 'any'); % allow handle arrays too
            ax.anchorInfo = AutoAxis.AnchorInfo.empty(0,1);
            
            % we use slightly different black colors here to make things
            % easily selectable by appearance in Illustrator
            sz = get(0, 'DefaultAxesFontSize');
            ax.tickColor = [3 3 3] / 255;
            ax.tickLineWidth = 1;
            ax.tickFontSize = sz;
            ax.tickFontColor = [2 2 2] / 255;
            
            ax.labelFontColor = [1 1 1] / 255;
            ax.labelFontSize = sz;
            
            ax.titleFontSize = sz;
            ax.titleFontColor = [0 0 0] / 255;
        end
        
        function installCallbacks(ax)
%             lh(1) = addlistener(ax.axh, {'XLim', 'YLim'}, ...
%                 'PostSet', @ax.updateLimsCallback);
            figh = ax.getParentFigure();
            set(zoom(ax.axh),'ActionPostCallback',@ax.updateLimsCallback);
            set(pan(figh),'ActionPostCallback',@ax.updateLimsCallback);
            set(figh, 'ResizeFcn', @ax.updateFigSizeCallback);
            %addlistener(ax.axh, 'Position', 'PostSet', @ax.updateFigSizeCallback);
        end
        
         function uninstall(ax)
%             lh(1) = addlistener(ax.axh, {'XLim', 'YLim'}, ...
%                 'PostSet', @ax.updateLimsCallback);
            return;
            figh = ax.getParentFigure();
            set(pan(figh),'ActionPostCallback', []);
            set(figh, 'ResizeFcn', []);
            %addlistener(ax.axh, 'Position', 'PostSet', @ax.updateFigSizeCallback);
        end
        
        function fig = getParentFigure(ax)
            % if the object is a figure or figure descendent, return the
            % figure. Otherwise return [].
            fig = ax.axh;
            while ~isempty(fig) && ~strcmp('figure', get(fig,'type'))
              fig = get(fig,'parent');
            end
        end
        
        function tf = checkLimsChanged(ax)
            tf = ~isequal(get(ax.axh, 'XLim'), ax.lastXLim) || ...
                ~isequal(get(ax.axh, 'YLim'), ax.lastYLim);
        end
        
        function updateLimsCallback(ax, varargin)
            if ax.isMultipleCall(), return, end;
                
            if ax.checkLimsChanged()
                ax.update();
            end
        end
        
        function updateFigSizeCallback(ax, varargin)
            if ax.isMultipleCall(), return, end;
            ax.update();
        end
        
        function flag = isMultipleCall(ax) %#ok<MANU>
            flag = false; 
            % Get the stack
            s = dbstack();
            if numel(s) <= 2
                % Stack too short for a multiple call
                return
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
        
        function addHandlesToCollection(ax, name, hvec)
            % add handles in hvec to the list ax.(name), updating all
            % anchors that involve that handle
            
            oldHvec = ax.(name);
            newHvec = makecol(union(oldHvec, hvec));
            
            % install the new handles
            ax.(name) = newHvec;
            
            % loop through anchors and replace oldHvec with new
            if isempty(oldHvec)
                return;
            end
            for i = 1:numel(ax.anchorInfo)
                ai = ax.anchorInfo(i);
                if isequal(ai.h, oldHvec)
                    ai.h = newHvec;
                end
                if isequal(ai.ha, oldHvec)
                    ai.ha = newHvec;
                end
            end
        end
        
        function names = listHandleCollections(ax) %#ok<MANU>
            % return a list of all handle collection properties
            names = {'hBelowX', 'hLeftY'};
        end
        
        function removeHandles(ax, hvec)
            % remove handles from all handle collections and from each
            % anchor that refers to it. Prunes anchors that become empty
            % after pruning.
            if isempty(hvec)
                return;
            end
            
            names = ax.listHandleCollections();
            
            % remove from all handle collections
            for i = 1:numel(names)
                ax.(names{i}) = setdiff(ax.(names{i}), hvec);
            end
            
            % remove from all anchors
            remove = false(numel(ax.anchorInfo), 1);
            for i = 1:numel(ax.anchorInfo)
                ai = ax.anchorInfo(i);
                if ~isempty(ai.h)
                    ai.h = setdiff(ai.h, hvec);
                    if isempty(ai.h), remove(i) = true; end
                end
                if ~isempty(ai.ha)
                    ai.ha = setdiff(ai.ha, hvec);
                    if isempty(ai.ha), remove(i) = true; end
                end
            end
            
            % filter the anchors for ones that still have some handles in
            % them
            ax.anchorInfo = ax.anchorInfo(~remove);
        end
    end
    
    methods(Static)
        function ax = replace(axh)
            % automatically replace title, axis labels, and ticks

            if nargin < 1
                axh = gca;
            end

            ax = AutoAxis(axh);
            axis(axh, 'off');
            ax.addAutoAxisX();
            ax.addAutoAxisY();
            ax.addTitle();
            ax.update();
        end
    end

    methods 
        function addXLabel(ax, varargin)
            % anchors and formats the existing x label
            
            p = inputParser();
            p.addOptional('xlabel', '', @ischar);
            p.parse(varargin{:});
            
            if ~isempty(p.Results.xlabel)
                xlabel(ax.axh, p.Results.xlabel);
            end
            
            import AutoAxis.PositionType;
            
            if ~isempty(ax.hXLabel)
                return;
            end
            
            hlabel = get(ax.axh, 'XLabel');
            set(hlabel, 'Visible', 'on', ...
                'FontSize', ax.labelFontSize, 'Margin', 0.1, ...
                'Color', ax.labelFontColor, 'HorizontalAlign', 'center', 'VerticalAlign', 'top');
            if ax.debug
                set(hlabel, 'EdgeColor', 'r');
            end
            
            % anchor below the hBelowX objects
            ai = AutoAxis.AnchorInfo(hlabel, PositionType.Top, ...
                ax.hBelowX, PositionType.Bottom, ax.labelOffset, ...
                'xlabel below hBelowX');
            ax.addAnchor(ai);
            
            % and in the middle of the x axis
            ai = AutoAxis.AnchorInfo(hlabel, PositionType.HCenter, ...
                ax.axh, PositionType.HCenter, 0, 'xLabel centered on x axis');
            ax.addAnchor(ai);
            ax.hXLabel = hlabel;
        end
        
        function addYLabel(ax, varargin)
            % anchors and formats the existing y label
            import AutoAxis.PositionType;
            
            p = inputParser();
            p.addOptional('ylabel', '', @ischar);
            p.parse(varargin{:});
            
            if ~isempty(p.Results.ylabel)
                ylabel(ax.axh, p.Results.ylabel);
            end
            
            hlabel = get(ax.axh, 'YLabel');
            set(hlabel, 'Visible', 'on', ...
                'FontSize', ax.labelFontSize, ...
                'Rotation', 90, 'Margin', 0.1, 'Color', ax.labelFontColor, ...
                'HorizontalAlign', 'center', 'VerticalAlign', 'bottom');
            if ax.debug
                set(hlabel, 'EdgeColor', 'r');
            end
            
            % anchor left of hLeftY objects
            ai = AutoAxis.AnchorInfo(hlabel, PositionType.Right, ...
                ax.hLeftY, PositionType.Left, ax.labelOffset);
            ax.addAnchor(ai);
            
            % and in the middle of the y axis
            ai = AutoAxis.AnchorInfo(hlabel, PositionType.VCenter, ...
                ax.axh, PositionType.VCenter, 0, 'yLabel centered on y axis');
            ax.addAnchor(ai);
            
            ax.hYLabel = hlabel;
        end
        
        function addAutoAxisX(ax, varargin)
            import AutoAxis.PositionType;
            if ~isempty(ax.autoAxisX)
                % delete the old axes
                delete(ax.autoAxisX.ht);
                delete(ax.autoAxisX.hl);
                
                remove = [ax.autoAxisX.ht; ax.autoAxisX.hl];
            else
                remove = [];
            end
            
            [hl, ht] = ax.addTickBridge('x');
            ax.autoAxisX.hl = hl;
            ax.autoAxisX.ht = ht;
            
            % remove after the new ones are added by addTickBridge
            % so that anchors aren't deleted
            ax.removeHandles(remove);
            
            ax.addXLabel();
        end
        
        function addAutoAxisY(ax, varargin)
            import AutoAxis.PositionType;
            if ~isempty(ax.autoAxisY)
                % delete the old objects
                delete(ax.autoAxisY.ht);
                delete(ax.autoAxisY.hl);
                
                % remove from handle collection
                remove = [ax.autoAxisY.ht; ax.autoAxisY.hl];
            else
                remove = [];
            end
            
            [hl, ht] = ax.addTickBridge('y');
            ax.autoAxisY.hl = hl;
            ax.autoAxisY.ht = ht;
            
            % remove after the new ones are added by addTickBridge
            % so that anchors aren't deleted
            ax.removeHandles(remove);
            
            ax.addYLabel();
        end
        
        function addAutoScaleBarX(ax, varargin)
            % adds a scale bar to the x axis that will automatically update
            % its length to match the major tick interval along the x axis
            if ~isempty(ax.autoScaleBarX)
                % delete the old objects
                delete(ax.autoScaleBarX.ht);
                delete(ax.autoScaleBarX.hr);
                
                % remove from handle collection
                remove = [ax.autoScaleBarX.hr; ax.autoScaleBarX.ht];
            else
                remove = [];
            end
            
            [ax.autoScaleBarX.hr, ax.autoScaleBarX.ht] = ax.addScaleBar('x', ...
                'thickness', ax.scaleBarThickness', 'units', ax.xUnits);
            
            % remove after the new ones are added by addTickBridge
            % so that the existing anchors aren't deleted
            ax.removeHandles(remove);
        end
        
        function addAutoScaleBarY(ax, varargin)
            % adds a scale bar to the x axis that will automatically update
            % its length to match the major tick interval along the x axis
            if ~isempty(ax.autoScaleBarY)
                % delete the old objects
                delete(ax.autoScaleBarY.ht);
                delete(ax.autoScaleBarY.hr);
                
                % remove from handle collection
                remove = [ax.autoScaleBarY.hr; ax.autoScaleBarY.ht];
            else
                remove = [];
            end
            
            [ax.autoScaleBarY.hr, ax.autoScaleBarY.ht] = ax.addScaleBar('y', ...
                'thickness', ax.scaleBarThickness, 'units', ax.yUnits);
            
            % remove after the new ones are added by addTickBridge
            % so that the existing anchors aren't deleted
            ax.removeHandles(remove);
        end
        
        function addTitle(ax, varargin)
            import AutoAxis.PositionType;
            
            p = inputParser();
            p.addOptional('title', '', @ischar);
            p.parse(varargin{:});
            
            if ~isempty(p.Results.title)
                title(ax.axh, p.Results.title);
            end
            
            hlabel = get(ax.axh, 'Title');
            %hlabel = text(0, 0, str,
            set(hlabel, 'FontSize', ax.titleFontSize, 'Color', ax.titleFontColor, ...
                'Margin', 0.1, 'HorizontalAlign', 'center', ...
                'VerticalAlign', 'bottom');
            if ax.debug
                set(hlabel, 'EdgeColor', 'r');
            end
            ai = AutoAxis.AnchorInfo(hlabel, PositionType.Bottom, ...
                ax.axh, PositionType.Top, ax.axisMargin(4), 'Title above axis');
            ax.addAnchor(ai);
            ai = AutoAxis.AnchorInfo(hlabel, PositionType.HCenter, ...
                ax.axh, PositionType.HCenter, 0, 'Title centered on axis');
            ax.addAnchor(ai);
            
            ax.hTitle = hlabel;
        end
        
        function addTicklessLabels(ax, varargin)
            % add labels to x or y axis where ticks would appear but
            % without the tick marks, i.e. positioned labels
            import AutoAxis.AnchorInfo;
            import AutoAxis.PositionType;
            
            p = inputParser();
            p.addRequired('orientation', @ischar);
            p.addParamValue('tick', [], @isvector);
            p.addParamValue('tickLabel', {}, @(x) isempty(x) || iscellstr(x));
            p.addParamValue('tickAlignment', [], @(x) isempty(x) || iscellstr(x));
            p.CaseSensitive = false;
            p.parse(varargin{:});
            
            axh = ax.axh;
            useX = strcmp(p.Results.orientation, 'x');
            if ~isempty(p.Results.tick)
                ticks = p.Results.tick;
                labels = p.Results.tickLabel;
            else
                ticks = get(axh, 'XTick');
                labels = get(axh, 'XTickLabel');
                labels = strtrim(mat2cell(labels, ones(size(labels,1),1), size(labels, 2)));
            end
            
            if isempty(labels)
                labels = sprintfc('%g', ticks);
            end
            
            if isempty(p.Results.tickAlignment)
                if useX
                    tickAlignment = repmat({'center'}, numel(ticks), 1);
                else
                    tickAlignment = repmat({'middle'}, numel(ticks), 1);
                end
            else
                tickAlignment = p.Result.tickAlignment;
            end
            
            color = ax.tickColor;
            fontSize = ax.tickFontSize;
            
            % generate line, ignore length here, we'll anchor that later
            if useX
                xtext = ticks;
                ytext = 0 * ticks;
                ha = tickAlignment;
                va = repmat({'top'}, numel(ticks), 1);
                offset = ax.axisMargin(2);
                
            else
                % y axis labels
                xtext = 0* ticks;
                ytext = ticks;
                ha = repmat({'right'}, numel(ticks), 1);
                va = tickAlignment;
                offset = ax.axisMargin(1);
            end
            
            ht = nan(numel(ticks), 1);
            for i = 1:numel(ticks)
                ht(i) = text(xtext(i), ytext(i), labels{i}, ...
                    'HorizontalAlignment', ha{i}, 'VerticalAlignment', va{i}, ...
                    'Interpreter', 'none', 'Parent', ax.axh);
            end
            set(ht, 'Clipping', 'off', 'Margin', 0.1, 'FontSize', fontSize, ...
                    'Color', color);
                
            if ax.debug
                set(ht, 'EdgeColor', 'r');
            end
            
            % build anchor for labels to axis
            if useX
                ai = AnchorInfo(ht, PositionType.Top, ax.axh, ...
                    PositionType.Bottom, offset, 'xTicklessLabels below axis');
                ax.addAnchor(ai);
            else
                ai = AnchorInfo(ht, PositionType.Right, ...
                    ax.axh, PositionType.Left, offset, 'yTicklessLabels left of axis');
                ax.addAnchor(ai);
            end
            
            % add handles to handle collections
            ht = makecol(ht);
            if useX
                ax.addHandlesToCollection('hBelowX', ht);
            else
                ax.addHandlesToCollection('hLeftY', ht);
            end
        end
        
        function [hl, ht] = addTickBridge(ax, varargin)
            % add line and text objects to the axis that replace the normal
            % axes
            import AutoAxis.AnchorInfo;
            import AutoAxis.PositionType;
            
            p = inputParser();
            p.addRequired('orientation', @ischar);
            p.addParamValue('tick', [], @isvector);
            p.addParamValue('tickLabel', {}, @(x) isempty(x) || iscellstr(x));
            p.addParamValue('tickAlignment', [], @(x) isempty(x) || iscellstr(x));
            p.CaseSensitive = false;
            p.parse(varargin{:});
            
            axh = ax.axh; %#ok<*PROP>
            useX = strcmp(p.Results.orientation, 'x');
            if ~isempty(p.Results.tick)
                ticks = p.Results.tick;
                labels = p.Results.tickLabel;
            else
                if useX
                    ticks = get(axh, 'XTick');
                    labels = get(axh, 'XTickLabel');
                else
                    ticks = get(axh, 'YTick');
                    labels = get(axh, 'YTickLabel');
                end
                labels = strtrim(mat2cell(labels, ones(size(labels,1),1), size(labels, 2)));
            end
            
            if isempty(labels)
                labels = sprintfc('%g', ticks);
            end
            
            if isempty(p.Results.tickAlignment)
                if useX
                    tickAlignment = repmat({'center'}, numel(ticks), 1);
                else
                    tickAlignment = repmat({'middle'}, numel(ticks), 1);
                end
            else
                tickAlignment = p.Results.tickAlignment;
            end
            
            tickLen = ax.tickLength;
            lineWidth = ax.tickLineWidth;
            color = ax.tickColor;
            fontSize = ax.tickFontSize;
            
            % generate line, ignore length here, we'll anchor that later
            if useX
                hi = 1;
                lo = 0;
                xvals = cat(2, [makerow(ticks); makerow(ticks)], ...
                    [min(ticks); max(ticks)]);
                yvals = cat(2, repmat([hi; lo], 1, numel(ticks)), [hi; hi]);
                
                xtext = ticks;
                ytext = repmat(lo, size(ticks));
                ha = tickAlignment;
                va = repmat({'top'}, numel(ticks), 1);
                offset = ax.axisMargin(2);
                
            else
                % y axis ticks
                lo = 0;
                hi = 1;
                
                yvals = cat(2, [makerow(ticks); makerow(ticks)], ...
                    [min(ticks); max(ticks)]);
                xvals = cat(2, repmat([hi; lo], 1, numel(ticks)), [hi; hi]);
                
                xtext = repmat(lo, size(ticks));
                ytext = ticks;
                ha = repmat({'right'}, numel(ticks), 1);
                va = tickAlignment;
                offset = ax.axisMargin(1);
            end
            
            hl = line(xvals, yvals, 'LineWidth', lineWidth, 'Color', color, 'Parent', ax.axh);
            set(hl, 'Clipping', 'off', 'YLimInclude', 'off', 'XLimInclude', 'off');
            ht = nan(numel(ticks), 1);
            for i = 1:numel(ticks)
                ht(i) = text(xtext(i), ytext(i), labels{i}, ...
                    'HorizontalAlignment', ha{i}, 'VerticalAlignment', va{i}, ...
                    'Parent', ax.axh);
            end
            set(ht, 'Clipping', 'off', 'Margin', 0.1, 'FontSize', fontSize, ...
                    'Color', color);
                
            if ax.debug
                set(ht, 'EdgeColor', 'r');
            end
            
            % build anchor for lines
            if useX
                ai = AnchorInfo(hl, PositionType.Top, ax.axh, ...
                    PositionType.Bottom, offset, 'xTick below axis');
                ax.addAnchor(ai);
                ai = AnchorInfo(hl, PositionType.Height, ...
                    [], tickLen, 0, 'xTick length');
                ax.addAnchor(ai);
            else
                ai = AnchorInfo(hl, PositionType.Right, ...
                    ax.axh, PositionType.Left, offset, 'yTick left of axis');
                ax.addAnchor(ai);
                ai = AnchorInfo(hl, PositionType.Width, ...
                    [], tickLen, 0, 'yTick length');
                ax.addAnchor(ai);
            end
            
            % anchor labels to lines
            if useX
                ai = AnchorInfo(ht, PositionType.Top, ...
                    hl, PositionType.Bottom, ax.tickLabelOffset, ...
                    'xTickLabels below ticks');
                ax.addAnchor(ai);
            else
                ai = AnchorInfo(ht, PositionType.Right, ...
                    hl, PositionType.Left, ax.tickLabelOffset, ...
                    'yTickLabels left of ticks');
                ax.addAnchor(ai);
            end
            
            % add handles to handle collections
            ht = makecol(ht);
            hl = makecol(hl);
            if useX
                ax.addHandlesToCollection('hBelowX', [hl; ht]);
            else
                ax.addHandlesToCollection('hLeftY', [hl; ht]);
            end
        end   
        
        function [hm, ht] = addMarkerX(ax, varargin)
            import AutoAxis.PositionType;
            
            p = inputParser();
            p.addRequired('x', @isscalar);
            p.addOptional('label', '', @ischar);
            p.addParamValue('labelColor', ax.tickFontColor, @(x) isvector(x) || isempty(x) || ischar(x));
            p.addParamValue('marker', 'o', @(x) isempty(x) || ischar(x));
            p.addParamValue('markerSize', 0.4, @isscalar);
            p.addParamValue('markerColor', [0.1 0.1 0.1], @(x) isvector(x) || ischar(x) || isempty(x));
            p.addParamValue('interval', [], @(x) isempty(x) || isvector(x)); % add a rectangle interval behind the marker to indicate a range of locations
            p.addParamValue('intervalColor', [0.5 0.5 0.5], @(x) isvector(x) || ischar(x) || isempty(x));
            p.CaseSensitive = false;
            p.parse(varargin{:});
            
            label = p.Results.label;
            
            markerSize = p.Results.markerSize;
            markerSizePoints = markerSize * 72 / 2.54;
            if strcmp(p.Results.marker, '.')
                markerSizePoints = markerSizePoints * 2;
            end
            
            yl = get(ax.axh, 'YLim');
            
            % add the interval rectangle if necessary, so that it sits
            % beneath the marker
            hr = [];
            hasInterval = false;
            if ~isempty(p.Results.interval)
                interval = p.Results.interval;
                assert(numel(interval) == 2, 'Interval must be a vector with length 2');
                
                if interval(2) - interval(1) > 0
                    hasInterval = true;
                    % set the height later
                    hr = rectangle('Position', [interval(1), yl(1), interval(2)-interval(1), 1], ...
                        'EdgeColor', 'none', 'FaceColor', p.Results.intervalColor, ...
                        'YLimInclude', 'off', 'XLimInclude', 'off', 'Clipping', 'off', 'Parent', ax.axh);
                end
            end
            
            hm = plot(p.Results.x, yl(1), 'Marker', p.Results.marker, ...
                'MarkerSize', markerSizePoints, 'MarkerFaceColor', p.Results.markerColor, ...
                'MarkerEdgeColor', 'none', 'YLimInclude', 'off', 'XLimInclude', 'off', ...
                'Clipping', 'off', 'Parent', ax.axh);
            
            ht = text(p.Results.x, yl(1), p.Results.label, ...
                'FontSize', ax.tickFontSize, 'Color', p.Results.labelColor, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
                'Parent', ax.axh);
            
            ai = AutoAxis.AnchorInfo(hm, PositionType.Top, ...
                ax.axh, PositionType.Bottom, ax.axisMargin(2), ...
                sprintf('markerX ''%s'' to bottom of axis', label));
            ax.addAnchor(ai);
            
            ai = AutoAxis.AnchorInfo(ht, PositionType.Top, ...
                hm, PositionType.Bottom, ax.tickLabelOffset, ...
                sprintf('markerX label ''%s'' to marker', label));
            ax.addAnchor(ai);
                   
            if hasInterval
                ai = AutoAxis.AnchorInfo(hr, PositionType.Height, ...
                    [], markerSize/3, 0, 'markerX interval rect height');
                ax.addAnchor(ai);
                ai = AutoAxis.AnchorInfo(hr, PositionType.VCenter, ...
                    hm, PositionType.VCenter, 0, 'markerX interval rect to marker');
                ax.addAnchor(ai);
            end
                        
            % add to hBelowX handle collection to update the dependent
            % anchors
            ax.addHandlesToCollection('hBelowX', [hm; ht; hr]);
        end
        
        function [hr, ht] = addScaleBar(ax, varargin)
            % add rectangular scale bar with text label to either the x or
            % y axis, at the lower right corner
            import AutoAxis.AnchorInfo;
            import AutoAxis.PositionType;
            
            p = inputParser();
            p.addRequired('orientation', @ischar);
            p.addParamValue('length', [], @isvector);
            p.addParamValue('thickness', ax.tickLength, @isscalar);
            p.addParamValue('units', '', @(x) isempty(x) || ischar(x));
            p.CaseSensitive = false;
            p.parse(varargin{:});
            
            axh = ax.axh; %#ok<*PROP>
            useX = strcmp(p.Results.orientation, 'x');
            if ~isempty(p.Results.length)
                len = p.Results.length;
            else
                ticks = get(ax.axh, 'XTick');
                len = ticks(end) - ticks(end-1);
            end
            
            if isempty(p.Results.units)
                label = sprintf('%g', len);
            else
                label = sprintf('%g %s', len, p.Results.units);
            end
           
            color = ax.tickColor;
            fontSize = ax.tickFontSize;
            thickness = p.Results.thickness;
            
            xl = get(axh, 'XLim');
            yl = get(axh, 'YLim');
            if useX
                hr = rectangle('Position', [xl(2) - len, yl(1), len, thickness], ...
                    'Parent', ax.axh);
                ht = text(xl(2), yl(1), label, 'HorizontalAlignment', 'right', ...
                    'VerticalAlignment', 'top', 'Parent', ax.axh);
            else
                hr = rectangle('Position', [xl(2) - thickness, yl(1), thickness, len], ...
                    'Parent', ax.axh);
                ht = text(xl(2), yl(1), label, 'HorizontalAlignment', 'left', ...
                    'VerticalAlignment', 'top', 'Parent', ax.axh);
            end
            
            set(hr, 'FaceColor', color, 'EdgeColor', 'none', 'Clipping', 'off', ...
                'XLimInclude', 'off', 'YLimInclude', 'off');
            set(ht, 'FontSize', fontSize, 'Margin', 0.1, 'Color', color, 'Clipping', 'off');
                
            if ax.debug
                set(ht, 'EdgeColor', 'r');
            end
            
            % build anchor for rectangle and label
            if useX
                ai = AnchorInfo(hr, PositionType.Height, [], thickness, 0, 'xScaleBar thickness');
                ax.addAnchor(ai);
                ai = AnchorInfo(hr, PositionType.Top, ax.axh, ...
                    PositionType.Bottom, ax.axisMargin(2), 'xScaleBar below axis');
                ax.addAnchor(ai);
                ai = AnchorInfo(hr, PositionType.Right, ax.axh, ...
                    PositionType.Right, ax.axisMargin(3) + thickness, 'xScaleBar right edge of axis');
                ax.addAnchor(ai);
                ai = AnchorInfo(ht, PositionType.Top, hr, PositionType.Bottom, 0, 'xScaleBarLabel below xScaleBar');
                ax.addAnchor(ai);
                ai = AnchorInfo(ht, PositionType.Right, hr, PositionType.Right, 0, 'xScaleBarLabel right edge of xScaleBar');
                ax.addAnchor(ai);
            else
                ai = AnchorInfo(hr, PositionType.Width, [], thickness, 0, 'yScaleBar thickness');
                ax.addAnchor(ai);
                ai = AnchorInfo(hr, PositionType.Left, ax.axh, ...
                    PositionType.Right, ax.axisMargin(3), 'yScaleBar right of axis');
                ax.addAnchor(ai);
                ai = AnchorInfo(hr, PositionType.Bottom, ax.axh, ...
                    PositionType.Bottom, ax.axisMargin(2) + thickness, 'yScaleBar bottom edge of axis');
                ax.addAnchor(ai);
                ai = AnchorInfo(ht, PositionType.Left, hr, PositionType.Right, 0, 'yScaleBarLabel right of yScaleBar');
                ax.addAnchor(ai);
                ai = AnchorInfo(ht, PositionType.Top, hr, PositionType.Top, 0, 'yScaleBarLabel top edge of xScaleBar');
                ax.addAnchor(ai);
            end
           
            % add handles to handle collections
            if useX
                ax.addHandlesToCollection('hBelowX', [hr; ht]);
            else
                ax.addHandlesToCollection('hRightY', [hr; ht]);
            end
        end
        
        function [hr, ht] = addIntervalX(ax, varargin)
            % add rectangular bar with text label to either the x or
            % y axis, at the lower right corner
            import AutoAxis.AnchorInfo;
            import AutoAxis.PositionType;
            
            p = inputParser();
            p.addRequired('interval', @(x) isvector(x) && numel(x) == 2);
            p.addOptional('label', '', @ischar);
            p.addParamValue('labelColor', ax.tickFontColor, @(x) isvector(x) || isempty(x) || ischar(x));
            p.addParamValue('thickness', 0.4, @isscalar);
            p.addParamValue('color', [0.1 0.1 0.1], @(x) isvector(x) || ischar(x) || isempty(x));    
            p.addParamValue('errorInterval', [], @(x) isempty(x) || (isvector(x) && numel(x) == 2)); % a background rectangle drawn to indicate error in the placement of the main interval
            p.addParamValue('errorIntervalColor', [0.5 0.5 0.5], @(x) isvector(x) || isempty(x) || ischar(x));
            p.CaseSensitive = false;
            p.parse(varargin{:});
            
            axh = ax.axh; %#ok<*PROP>
            
            interval = p.Results.interval;
            color = p.Results.color;
            label = p.Results.label;
            errorInterval = p.Results.errorInterval;
            errorIntervalColor = p.Results.errorIntervalColor;
            fontSize = ax.tickFontSize;
            thickness = p.Results.thickness;
            
            yl = get(axh, 'YLim');
            if ~isempty(errorInterval)
                hre = rectangle('Position', [errorInterval(1), yl(1), ...
                    errorInterval(2)-errorInterval(1), thickness/3], ...
                    'Parent', ax.axh);
                set(hre, 'FaceColor', errorIntervalColor, 'EdgeColor', 'none', ...
                    'Clipping', 'off', 'XLimInclude', 'off', 'YLimInclude', 'off');
            else
                hre = [];
            end
            hri = rectangle('Position', [interval(1), yl(1), interval(2)-interval(1), thickness], ...
                'Parent', ax.axh);
            
            hr = [hri; hre];
            ht = text(mean(interval), yl(1), label, 'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'top', 'Parent', ax.axh);

            set(hri, 'FaceColor', color, 'EdgeColor', 'none', 'Clipping', 'off', ...
                'XLimInclude', 'off', 'YLimInclude', 'off');
            
            set(ht, 'FontSize', fontSize, 'Margin', 0.1, 'Color', p.Results.labelColor);
                
            if ax.debug
                set(ht, 'EdgeColor', 'r');
            end
            
            % build anchor for rectangle and label
            ai = AnchorInfo(hri, PositionType.Height, [], thickness, 0, ...
                sprintf('interval ''%s'' thickness', label));
            ax.addAnchor(ai);
            ai = AnchorInfo(hri, PositionType.Top, ax.axh, ...
                PositionType.Bottom, ax.axisMargin(2), ...
                sprintf('interval ''%s'' below axis', label));
            ax.addAnchor(ai);

            ai = AnchorInfo(ht, PositionType.Top, ...
                hr, PositionType.Bottom, ax.tickLabelOffset, ...
                sprintf('interval label ''%s'' below interval', label));
            ax.addAnchor(ai);

            if ~isempty(hre)
                ai = AnchorInfo(hre, PositionType.Height, [], thickness/3, 0, ...
                    sprintf('interval ''%s'' error thickness', label));
                ax.addAnchor(ai);
                ai = AnchorInfo(hre, PositionType.VCenter, hri, PositionType.VCenter, 0, ...
                    sprintf('interval ''%s'' error centered in interval', label));
                ax.addAnchor(ai);
            end  
           
            % add handles to handle collections
            ax.addHandlesToCollection('hBelowX', [hr; ht]);
        end
        
        function addAnchor(ax, info)
            ind = numel(ax.anchorInfo) + 1;
            ax.anchorInfo(ind) = info;
        end
        
        function update(ax)
            if ~ishandle(ax.axh)
                ax.uninstall();
                return;
            end
            
            ax.locMap = ValueMap('KeyType', 'any', 'ValueType', 'any'); % allow handle vectors

            ax.updateAxisScaling();
                        
            % recreate the old auto axes
            if ~isempty(ax.autoAxisX)
                ax.addAutoAxisX();
            end
            if ~isempty(ax.autoAxisY)
                ax.addAutoAxisY();
            end
            if ~isempty(ax.autoScaleBarX)
                ax.addAutoScaleBarX();
            end
            if ~isempty(ax.autoScaleBarY)
                ax.addAutoScaleBarY();
            end
            if ~isempty(ax.hXLabel)
                set(ax.hXLabel, 'Visible', 'on');
            end
            if ~isempty(ax.hYLabel)
                set(ax.hYLabel, 'Visible', 'on');
            end

            % reset the processed flag
            if ~isempty(ax.anchorInfo)
                [ax.anchorInfo.processed] = deal(false);
            
                ax.processAnchors(ax.anchorInfo);
            end
            
            % cache the current limits for checking for changes in
            % callbacks
            ax.lastXLim = get(ax.axh, 'XLim');
            ax.lastYLim = get(ax.axh, 'YLim');
        end

        function updateAxisScaling(ax)
            % set x/yDataToUnits scaling from data to paper units
            axh = ax.axh;
            axlim = axis(axh);
            axwidth = diff(axlim(1:2));
            axheight = diff(axlim(3:4));
            axUnits = get(axh,'Units');
            
            % get data to paper conversion
            set(axh,'Units','centimeters');
            
            set(axh, 'LooseInset', ax.axisInset);
            
            axpos = get(axh,'Position');
            ax.xDataToUnits = axpos(3)/axwidth;
            ax.yDataToUnits = axpos(4)/axheight;
            
            % get data to points conversion
            set(axh,'Units','points');
            axpos = get(axh,'Position');
            ax.xDataToPoints = axpos(3)/axwidth;
            ax.yDataToPoints = axpos(4)/axheight;
            
            % get data to pixels conversion
            set(axh,'Units','pixels');
            axpos = get(axh,'Position');
            ax.xDataToPixels = axpos(3)/axwidth;
            ax.yDataToPixels = axpos(4)/axheight;
            
            set(axh, 'Units', axUnits);
        end

        function processAnchors(ax, infoArray)
            for i = 1:numel(infoArray)
                info = infoArray(i);
                if ~info.processed
                    ax.processAnchor(info);
                end
            end
        end
        
        function loc = getOrCreateLocationInfo(ax, h)
            % return the LocationInfo for h, or create one if missing
            if ax.locMap.isKey(h)
                loc = ax.locMap(h);
            else
                loc = AutoAxis.LocationInfo();
                ax.locMap(h) = loc;
            end
        end
           
        
        function processAnchor(ax, info)
            import AutoAxis.PositionType;
            
            if info.processed
                return;
            end
            if isempty(info.h) || ~all(ishandle(info.h)) || ...
                (~isempty(info.ha) && ~all(ishandle(info.ha)))
                info.valid = false;
                warning('Invalid anchor %s encountered', info.desc);
                return;
            end
            
            if isempty(info.ha)
                % convert the scalar position value from paper to data
                % units
                pAnchor = info.posa;
                if info.pos.isX
                    pAnchor = pAnchor / ax.xDataToUnits;
                else
                    pAnchor = pAnchor / ax.yDataToUnits;
                end
            else
                % get the position of the anchoring element
                pAnchor = ax.getAnchorPosition(info.ha, info.posa);
            end

            field = info.pos.getDirectField();
            
            loc = ax.getOrCreateLocationInfo(info.h);

            % add margin to anchor in the correct direction if possible
            if ~isempty(info.ha) && ~isempty(info.margin) && ~isnan(info.margin)
                offset = 0;
                
                if info.posa == PositionType.Top
                    offset = info.margin / ax.yDataToUnits;
                elseif info.posa == PositionType.Bottom
                    offset = -info.margin / ax.yDataToUnits;
                elseif info.posa == PositionType.Left
                    offset = -info.margin / ax.xDataToUnits;
                elseif info.posa == PositionType.Right
                    offset = info.margin / ax.xDataToUnits;
                end
                
                pAnchor = pAnchor + offset;
            end
            
            % set the anchored position of this element to match
            loc.(field) = pAnchor;

            % and actually set the position of the data
            ax.updatePositionData(info.h, info.pos);
        end
        
        function info = findAnchorsSpecifying(ax, hVec, posType)
            % returns a list of AnchorInfo which could specify position posa of object h
            % this includes 
            import AutoAxis.PositionType;
            
            % first find any anchors that specify any subset of the handles in
            % hVec 
            maskSuperset = cellfun(@(v) any(ismember(hVec, v)), {ax.anchorInfo.h});
            maskExact = cellfun(@(v) isequal(hVec, v), {ax.anchorInfo.h});
            
            % then search for any directly or indirectly specifying anchors
            info = ax.anchorInfo(maskSuperset | maskExact);
            if isempty(info)
                info = [];
                return;
            end

            maskTop = [info.pos] == PositionType.Top;
            maskBottom = [info.pos] == PositionType.Bottom;
            maskVCenter = [info.pos] == PositionType.VCenter;
            maskLeft = [info.pos] == PositionType.Left;
            maskRight = [info.pos] == PositionType.Right;
            maskHCenter = [info.pos] == PositionType.HCenter;
            maskHeight = [info.pos] == PositionType.Height; 
            maskWidth = [info.pos] == PositionType.Width;

            % directly specified anchors
            maskDirect = [info.pos] == posType;

            % placeholder for implicit "combination" specifying anchors,
            % e.g. height and bottom specifying the top position
            maskImplicit = false(size(info));

            switch posType
                case PositionType.Top
                    if sum([any(maskBottom) any(maskHeight) any(maskVCenter)]) >= 2
                        maskImplicit = maskBottom | maskHeight | maskVCenter; 
                    end

                case PositionType.Bottom
                    if sum([any(maskTop) any(maskHeight) any(maskVCenter)]) >= 2
                        maskImplicit = maskTop | maskHeight | maskVCenter; 
                    end

                case PositionType.Height
                    if sum([any(maskTop) any(maskBottom) any(maskVCenter)]) >= 2
                        maskImplicit = maskTop | maskBottom | maskVCenter;
                    end

                case PositionType.VCenter
                    if sum([any(maskTop) any(maskBottom) any(maskHeight)]) >= 2
                        maskImplicit = maskTop | maskBottom | maskHeight;
                    end

                case PositionType.Left
                    if sum([any(maskRight) any(maskWidth) any(maskHCenter)]) >= 2
                        maskImplicit = maskRight | maskWidth | maskHCenter;
                    end

                case PositionType.Right
                    if sum([any(maskLeft) any(maskWidth) any(maskHCenter)]) >= 2
                        maskImplicit = maskLeft | maskWidth | maskHCenter; 
                    end

                case PositionType.Width
                    if sum([any(maskLeft) && any(maskRight) any(maskHCenter)]) >= 2
                        maskImplicit = maskLeft | maskRight | maskHCenter;
                    end

                case PositionType.HCenter
                    if sum([any(maskLeft) && any(maskRight) any(maskWidth)]) >= 2
                        maskImplicit = maskLeft | maskRight | maskWidth;
                    end
            end
            
            info = info(maskDirect | maskImplicit);
        end

        function pos = getAnchorPosition(ax, ha, posa)
            % for a given object ha and position type posa, return the
            % paper units figure 

            if isempty(ha)
                pos = posa;
                return;
            end
            
            loc = ax.getOrCreateLocationInfo(ha);

            field = posa.getDirectField();
            if isnan(loc.(field))
                % not specified yet

                % process any dependent anchors needed to determine this position
                dependentAnchors = ax.findAnchorsSpecifying(ha, posa);
                if ~isempty(dependentAnchors)
                    ax.processAnchors(dependentAnchors);
                end
            end

            if isnan(loc.(field))
                % still not specified, must not be anchored, use the current value
                loc.(field) = ax.getCurrentPositionData(ha, posa);
            end
                
            pos = loc.(field);
        end

        function pos = getCurrentPositionData(ax, hvec, posType)
            % grab the specified position / size value for object h, in figure units
            % when hvec is a vector of handles, uses the outer bounding
            % box for the objects instead
            
            import AutoAxis.PositionType;
            
            % compute derivative positions recursively
            pos = [];
            switch posType
                case PositionType.VCenter
                    top = ax.getCurrentPositionData(hvec, PositionType.Top);
                    bottom = ax.getCurrentPositionData(hvec, PositionType.Bottom);
                    pos = (top+bottom)/2;
                case PositionType.Height
                    top = ax.getCurrentPositionData(hvec, PositionType.Top);
                    bottom = ax.getCurrentPositionData(hvec, PositionType.Bottom);
                    pos = top - bottom;
                case PositionType.HCenter
                    left = ax.getCurrentPositionData(hvec, PositionType.Left);
                    right = ax.getCurrentPositionData(hvec, PositionType.Right);
                    pos = (left+right)/2;
                case PositionType.Width
                    left = ax.getCurrentPositionData(hvec, PositionType.Left);
                    right = ax.getCurrentPositionData(hvec, PositionType.Right);
                    pos = right - left;
            end
            if ~isempty(pos), return; end

            posVec = nan(numel(hvec), 1);
            for i = 1:numel(hvec)
                h = hvec(i);
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
                        
                        markerSizeX = markerSize / ax.xDataToPoints;
                        markerSizeY = markerSize / ax.yDataToPoints;
                        xdata = get(h, 'XData');
                        ydata = get(h, 'YData');
                        %npts = numel(xdata);

                        switch posType
                            case PositionType.Top
                                pos = nanmax(ydata) + markerSizeY/2;
                            case PositionType.Bottom
                                pos = nanmin(ydata) - markerSizeY/2;
                            case PositionType.Left
                                pos = nanmin(xdata) - markerSizeX/2;
                            case PositionType.Right
                                pos = nanmax(xdata) + markerSizeX/2;
                        end

                    case 'text'
                        set(h, 'Units', 'data');
                        ext = get(h, 'Extent'); % [left,bottom,width,height]
                        switch posType
                            case PositionType.Top
                                pos = ext(2) + ext(4);
                            case PositionType.Bottom
                                pos = ext(2);
                            case PositionType.Left
                                pos = ext(1);
                            case PositionType.Right
                                pos = ext(1) + ext(3);
                        end

                    case 'axes'
                        % return the limits of the axis...i.e. the coordinates
                        % of the inner position of the axis in data units
                        lim = axis(ax.axh);
                        switch posType
                            case PositionType.Top
                                pos = lim(4);
                            case PositionType.Bottom
                                pos = lim(3);
                            case PositionType.Left
                                pos = lim(1);
                            case PositionType.Right
                                pos = lim(2);
                        end
                        
                    case 'rectangle'
                        posv = get(h, 'Position');
                        switch posType
                            case PositionType.Top
                                pos = posv(2) + posv(4);
                            case PositionType.Bottom
                                pos = posv(2);
                            case PositionType.Left
                                pos = posv(1);
                            case PositionType.Right
                                pos = posv(1) + posv(3);
                        end
                end
                
                posVec(i) = pos;
            end
            
            % now compute min/max as appropriate
            switch posType
                case PositionType.Top
                    pos = nanmax(posVec);
                case PositionType.Bottom
                    pos = nanmin(posVec);
                case PositionType.Left
                    pos = nanmin(posVec);
                case PositionType.Right
                    pos = nanmax(posVec);
            end
        end
        
        function updatePositionData(ax, hVec, posType, value)
            % update the position of handles in vector hVec using the LocationInfo in 
            % ax.locMap. When hVec is a vector of handles, linearly shifts
            % each object to maintain the relative positions and to
            % shift the bounding box of the objects
            
            import AutoAxis.PositionType;
            
            loc = ax.getOrCreateLocationInfo(hVec);
            
            if nargin < 4
                value = loc.(posType.getDirectField());
            end
                
            if ~isscalar(hVec)
                % here we linearly scale / translate the bounding box
                % in order to maintain internal anchoring, scaling should
                % be done before any "internal" anchorings are computed,
                % which should be taken care of by findAnchorsSpecifying
                
                if posType == PositionType.Height
                    % scale everything vertically, but keep existing
                    % top/bottom/vcenter (of bounding box) in place if anchored
                    oldTop = ax.getCurrentPositionData(hVec, PositionType.Top);
                    oldBottom = ax.getCurrentPositionData(hVec, PositionType.Bottom);
                    
                    if ~isempty(loc.top)
                        newBottom = loc.top - value;
                    elseif ~isempty(loc.bottom)
                        newBottom = loc.bottom;
                    else
                        % keep vcenter in place
                        newBottom = (oldTop+oldBottom) / 2 - value/2;
                    end
                    
                    newPosFn = @(p) (p-oldBottom) * (value / (oldTop-oldBottom)) + newBottom;
                    newHeightFn = @(h) h * (value / (oldTop-oldBottom));
                    
                    % loop over each object and shift its position by offset
                    for i = 1:numel(hVec)
                       h = hVec(i);
                       t = ax.getCurrentPositionData(h, PositionType.Top);
                       he = ax.getCurrentPositionData(h, PositionType.Height);
                       ax.updatePositionData(h, PositionType.Height, newHeightFn(he));
                       ax.updatePositionData(h, PositionType.Top, newPosFn(t));
                    end
                
                elseif posType == PositionType.Width
                    % scale everything horizontally, but keep existing
                    % left/right/center (of bounding box) in place if anchored
                    oldRight = ax.getCurrentPositionData(hVec, PositionType.Right);
                    oldLeft = ax.getCurrentPositionData(hVec, PositionType.Left);
                    
                    if ~isempty(loc.right)
                        newLeft = loc.right - value;
                    elseif ~isempty(loc.left)
                        newLeft = loc.left;
                    else
                        % keep vcenter in place
                        newLeft = (oldRight+oldLeft) / 2 - value/2;
                    end
                    
                    newPosFn = @(p) (p-oldLeft) * (value / (oldRight-oldLeft)) + newLeft;
                    newWidthFn = @(w) w * value / (oldRight-oldLeft);
                    
                    % loop over each object and shift its position by offset
                    for i = 1:numel(hVec)
                       h = hVec(i);
                       l = ax.getCurrentPositionData(h, PositionType.Left);
                       w = ax.getCurrentPositionData(h, PositionType.Width);
                       ax.updatePositionData(h, PositionType.Width, newWidthFn(w));
                       ax.updatePositionData(h, PositionType.Left, newPosFn(l));
                    end
                    
                else
                    % shift each object to shift the bounding box 
                    offset = value - ax.getCurrentPositionData(hVec,  posType);
                    for i = 1:numel(hVec)
                       h = hVec(i);
                       p = ax.getCurrentPositionData(h, posType);
                       ax.updatePositionData(h, posType, p + offset);
                    end
                end
            else
                % scalar handle, just move it
                
                h = hVec(1);
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
                        markerSizeX = markerSize / ax.xDataToPoints;
                        markerSizeY = markerSize / ax.yDataToPoints;

                        xdata = get(h, 'XData');
                        ydata = get(h, 'YData');

                        % rescale the appropriate data points from their
                        % current values to scale linearly onto the new values
                        % but only along the dimension to be resized
                        switch posType
                            case PositionType.Top
                                ydata = ydata - nanmax(ydata) + value - markerSizeY/2;

                            case PositionType.Bottom
                                ydata = ydata - nanmin(ydata) + value + markerSizeY/2;

                            case PositionType.VCenter
                                lo = nanmin(ydata); hi = nanmax(ydata);
                                ydata = (ydata - (hi+lo)/2) + value;

                            case PositionType.Height
                                lo = nanmin(ydata); hi = nanmax(ydata);
                                if hi - lo < eps, return, end
                                ydata = (ydata - lo) / (hi - lo + markerSizeY) * value + lo;

                            case PositionType.Left
                                xdata = xdata - nanmin(xdata) + value - markerSizeX/2;

                            case PositionType.Right
                                xdata = xdata - nanmax(xdata) + value + markerSizeX/2;

                            case PositionType.HCenter
                                lo = nanmin(xdata); hi = nanmax(xdata);
                                xdata = (xdata - (hi+lo)/2) + value;

                            case PositionType.Width
                                lo = nanmin(xdata); hi = nanmax(xdata);
                                if hi - lo < eps, return, end
                                xdata = (xdata - lo) / (hi - lo + markerSizeX) * value + lo;
                        end

                        set(h, 'XData', xdata, 'YData', ydata);

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
                                p(2) = value - ext(4) - yoff;
                            case PositionType.Bottom
                                p(2) = value - yoff;
                            case PositionType.VCenter
                                p(2) = value - ext(4)/2 - yoff;

                            case PositionType.Right
                                p(1) = value - ext(3) - xoff;
                            case PositionType.Left
                                p(1) = value - xoff;
                            case PositionType.HCenter
                                p(1) = value - ext(3)/2 - xoff;
                        end

                        set(h, 'Position', p);
                        
                    case 'rectangle'
                        p = get(h, 'Position'); % [left, bottom, width, height]
                        
                        switch posType
                            case PositionType.Top
                                p(2) = value - p(4);
                            case PositionType.Bottom
                                p(2) = value;
                            case PositionType.VCenter
                                p(2) = value - p(4)/2;
                            case PositionType.Height
                                p(4) = value;
                            case PositionType.Right
                                p(1) = value - p(3);
                            case PositionType.Left
                                p(1) = value;
                            case PositionType.HCenter
                                p(1) = value - p(3)/2;
                            case PositionType.Width
                                p(3) = value;
                        end

                        set(h, 'Position', p);
                end
            end
        end
    end
    
    
end

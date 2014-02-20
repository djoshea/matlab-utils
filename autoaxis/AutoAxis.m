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
        
        axisTickLength % cm
        
        debug = false;
    end
    
    properties(SetAccess=protected)
        axh
        anchorInfo % array of AutoAxisAnchorInfo objects
        locMap % map handle -> AutoAxisLocationInfo instance
        
        % handles of objects sitting below x axis but above x axis label
        hBelowX = []
        
        % handles of objects sitting above y axis but right of y axis label
        hLeftY = []
        
        % these hold on to specific special objects that have been added
        % to the plot
        autoAxisX
        autoAxisY
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
            if nargin < 1
                axh = gca;
            end
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
            figh = getParentFigure(ax.axh);
            set(zoom(ax.axh),'ActionPostCallback',@ax.updateLimsCallback);
            set(pan(figh),'ActionPostCallback',@ax.updateLimsCallback);
            set(figh, 'ResizeFcn', @ax.updateFigSizeCallback);
            %addlistener(ax.axh, 'Position', 'PostSet', @ax.updateFigSizeCallback);
            
            function fig = getParentFigure(fig)
                % if the object is a figure or figure descendent, return the
                % figure. Otherwise return [].
                while ~isempty(fig) & ~strcmp('figure', get(fig,'type'))
                  fig = get(fig,'parent');
                end
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
        
        function flag = isMultipleCall(ax)
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
        
        function names = listHandleCollections(ax)
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
    
    methods 
        function addXLabel(ax, varargin)
            % anchors and formats the existing x label
            
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
            ai = AutoAxis.AnchorInfo(hlabel, PositionType.HCenter, ax.axh, PositionType.HCenter);
            ax.addAnchor(ai);
            ax.hXLabel = hlabel;
        end
        
        function addYLabel(ax, varargin)
            % anchors and formats the existing y label
            import AutoAxis.PositionType;
            
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
            ai = AutoAxis.AnchorInfo(hlabel, PositionType.VCenter, ax.axh, PositionType.VCenter);
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
        
        function addTitle(ax)
            import AutoAxis.PositionType;
            
            hlabel = get(gca, 'Title');
            %hlabel = text(0, 0, str,
            set(hlabel, 'FontSize', ax.titleFontSize, 'Color', ax.titleFontColor, ...
                'Margin', 0.1, 'HorizontalAlign', 'center', ...
                'VerticalAlign', 'bottom');
            if ax.debug
                set(hlabel, 'EdgeColor', 'r');
            end
            ai = AutoAxis.AnchorInfo(hlabel, PositionType.Bottom, ...
                ax.axh, PositionType.Top, ax.axisMargin(4));
            ax.addAnchor(ai);
            ai = AutoAxis.AnchorInfo(hlabel, PositionType.HCenter, ax.axh, PositionType.HCenter);
            ax.addAnchor(ai);
            
            ax.hTitle = hlabel;
        end
        
        function [hl, ht] = addTickBridge(ax, varargin)
            % add line and text objects to the axis that replace the normal
            % axes
            import AutoAxis.AnchorInfo;
            import AutoAxis.PositionType;
            
            p = inputParser();
            p.addOptional('orientation', 'x', @ischar);
            p.addParamValue('XTick', [], @isvector);
            p.addParamValue('XTickLabel', {}, @(x) isempty(x) || iscellstr);
            p.addParamValue('YTick', [], @isvector);
            p.addParamValue('YTickLabel', {}, @iscellstr);
            p.CaseSensitive = false;
            p.parse(varargin{:});
            
            axh = ax.axh; %#ok<*PROP>
            if ~isempty(p.Results.XTick)
                useX = true;
                ticks = p.Results.XTick;
                labels = p.Results.XTickLabel;
                
            elseif ~isempty(p.Results.YTick)
                useX = false;
                ticks = p.Results.YTick;
                labels = p.Results.YTickLabel;
                
            elseif strcmp(p.Results.orientation, 'x')
                useX = true;
                ticks = get(axh, 'XTick');
                labels = get(axh, 'XTickLabel');
                labels = strtrim(mat2cell(labels, ones(size(labels,1),1), size(labels, 2)));
                
            elseif strcmp(p.Results.orientation, 'y')
                useX = false;
                ticks = get(axh, 'YTick');
                labels = get(axh, 'YTickLabel');
                labels = strtrim(mat2cell(labels, ones(size(labels,1),1), size(labels, 2)));
                
            else
                error('Please specify orientation as ''x'' or ''y'' or specify ''XTick'' or ''YTick''');
            end
            
            if isempty(labels)
                labels = sprintfc('%g', ticks);
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
                ha = 'center';
                va = 'top';
                offset = ax.axisMargin(1);
                
            else
                % y axis ticks
                lo = 0;
                hi = 1;
                
                yvals = cat(2, [makerow(ticks); makerow(ticks)], ...
                    [min(ticks); max(ticks)]);
                xvals = cat(2, repmat([hi; lo], 1, numel(ticks)), [hi; hi]);
                
                xtext = repmat(lo, size(ticks));
                ytext = ticks;
                ha = 'right';
                va = 'middle';
                offset = ax.axisMargin(2);
            end
            
            hl = line(xvals, yvals, 'LineWidth', lineWidth, 'Color', color);
            set(hl, 'Clipping', 'off', 'YLimInclude', 'off', 'XLimInclude', 'off');
            ht = nan(numel(ticks), 1);
            for i = 1:numel(ticks)
                ht(i) = text(xtext(i), ytext(i), labels{i});
            end
            set(ht, 'HorizontalAlignment', ha, 'VerticalAlignment', va, ...
                    'Clipping', 'off', 'Margin', 0.1, 'FontSize', fontSize, ...
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
            p.addParamValue('marker', 'o', @(x) isempty(x) || ischar(x));
            p.addParamValue('markerSize', 0.1, @isscalar);
            p.addParamValue('markerColor', [0.5 0.5 0.5], @(x) isvector(x) || isempty(x) || isempty(x));
            p.CaseSensitive = false;
            p.parse(varargin{:});
            
            label = p.Results.label;
            
            markerSizePoints = p.Results.markerSize * 72 / 2.54;
            if strcmp(p.Results.marker, '.')
                markerSizePoints = markerSizePoints * 2;
            end
            
            yl = get(ax.axh, 'YLim');
            hm = plot(p.Results.x, yl(1), 'Marker', p.Results.marker, ...
                'MarkerSize', markerSizePoints, 'MarkerFaceColor', p.Results.markerColor, ...
                'MarkerEdgeColor', 'none', 'YLimInclude', 'off', 'XLimInclude', 'off', ...
                'Clipping', 'off');
            
            ht = text(p.Results.x, yl(1), p.Results.label, ...
                'FontSize', ax.tickFontSize, 'Color', ax.tickFontColor, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
            
            ai = AutoAxis.AnchorInfo(hm, PositionType.Top, ...
                ax.axh, PositionType.Bottom, ax.axisMargin(2), ...
                sprintf('markerX ''%s'' to bottom of axis', label));
            ax.addAnchor(ai);
            
            ai = AutoAxis.AnchorInfo(ht, PositionType.Top, ...
                hm, PositionType.Bottom, ax.tickLabelOffset, ...
                sprintf('markerX label ''%s'' to marker', label));
            ax.addAnchor(ai);
            
            % add to hBelowX handle collection to update the dependent
            % anchors
            ax.addHandlesToCollection('hBelowX', [hm; ht]);
        end
        
        function addAnchor(ax, info)
            ind = numel(ax.anchorInfo) + 1;
            ax.anchorInfo(ind) = info;
        end
        
        function update(ax)
            ax.locMap = ValueMap('KeyType', 'any', 'ValueType', 'any'); % allow handle vectors

            ax.updateAxisScaling();
                        
            % recreate the old auto axes
            if ~isempty(ax.autoAxisX)
                ax.addAutoAxisX();
            end
            if ~isempty(ax.autoAxisY)
                ax.addAutoAxisY();
            end
            if ~isempty(ax.hXLabel)
                set(ax.hXLabel, 'Visible', 'on');
            end
            if ~isempty(ax.hYLabel)
                set(ax.hYLabel, 'Visible', 'on');
            end

            % reset the processed flag
            [ax.anchorInfo.processed] = deal(false);
            
            ax.processAnchors(ax.anchorInfo);
            
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
                pos = [];
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
                end
            end
        end
    end
    
    
end

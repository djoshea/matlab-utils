classdef Container < handle
    properties
        ma % multiaxis instance this is assocaited with
        parent
        children = {}; % nRows x nCols cell of children
        labels % nRows x nCols cell of text labels
        gridInitialized = false;

        % specified by .grid()
        nRows = 1; % scalar
        nCols = 1; % scalar
        rowFrac % nRows - 1, will be normalized by sum
        colFrac % nRows - 1, will be normalized by sum
        shareX = false;
        shareY = false;
        
        % set manually!
        rowGap % in cm
        colGap % in cm
        padding % [left bottom right top] in cm
        
        defaultMargins = [2 2 1 1];
        smallMargin = 0.2;
        
        linkRows
        linkCols
    end
    
    properties % positions
        boxOuter % position determined by parent
        normToX
        normToY
        
        boxInner % position with padding
        boxChildren % 4 x nRows x nCols
    end
    
    methods
        function c = Container(p, boxOuter)
            if isa(p, 'MultiAxis')
                c.ma = p;
            else
                c.ma = p.ma;
            end
            
            c.parent = p;
            c.boxOuter = boxOuter;
            c.gridInitialized = false;
            c.padding = [0.2 0.2 0.2 0.2];
            c.colGap = 0.2;
            c.rowGap = 0.2;
        end
        
        function update(c, boxOuter, normToX, normToY)
            % box positions are [left bottom width height]
            
            c.boxOuter = boxOuter;
            c.normToX = normToX;
            c.normToY = normToY;
            
            paddingNorm = MultiAxis.Container.convertToNormalizedInset(c.padding, normToX, normToY);
            c.boxInner = MultiAxis.Container.reduceBoxByInset(boxOuter, paddingNorm);
            
            % figure out content size given gaps
            width = c.boxInner(3) - c.colGap/c.normToX*(c.nCols-1);
            height = c.boxInner(4) - c.rowGap/c.normToY*(c.nRows-1);
            
            % figure out position of each grid cell
            c.boxChildren = nan(4, c.nRows, c.nCols);
            
            normColFrac = c.colFrac/sum(c.colFrac);
            normRowFrac = c.rowFrac/sum(c.rowFrac);
            py = c.boxInner(2);
            for row = c.nRows:-1:1 % bottom to top
                px = c.boxInner(1);
                for col = 1:c.nCols % left to right
                    dx = normColFrac(col)*width;
                    dy = normRowFrac(row)*height;
                    c.boxChildren(:, row, col) = [px py dx dy]';
                    px = px + dx + c.colGap/normToX;
                end
                py = py + dy + c.rowGap/normToY;
            end
            
            % update children and reposition child axes
            for row = c.nRows:-1:1 % bottom to top
                for col = 1:c.nCols % left to right
                    child = c.children{row,col};
                    if isempty(child)
                        continue;
                    elseif isa(child, 'matlab.graphics.axis.Axes')
                        % first let AutoAxis ups
                        ax = AutoAxis.recoverForAxis(child);
                        if ~isempty(ax)
                            % we'll grab desired insets directly from
                            % AutoAxis since this is the intent
                            inset = MultiAxis.Container.convertToNormalizedInset(ax.axisMargin, normToX, normToY);
                        else
                            % determine the real inset by looking at
                            % OuterPosition and Position directly
                            inset = MultiAxis.Container.getActualAxisInset(child);
                        end
                        
                        % set the position by incorporating the loose
                        % inset, so that the actual position of the axis
                        % is as expected. Let matlab worry about tight
                        % inset and the outer position, it doesn't matter
                        % if that lines up correctly.
                        set(child, 'Units', 'normalized');
                        box = MultiAxis.Container.reduceBoxByInset(c.boxChildren(:, row, col), inset);
                    	set(child, 'ActivePositionProperty', 'Position', 'Position', box);
                        
                        if ~isempty(ax)
                            ax.update();
                        end
                    else
                        child.update(c.boxChildren(:, row, col), normToX, normToY);
                    end
                end
            end
            
            % update labels
            for row = 1:c.nRows
                for col = 1:c.nCols
                    h = c.labels(row, col);
                    if MultiAxis.isValidHandle(h)
                        posX = c.boxChildren(1, row, col);
                        posY = c.boxChildren(2, row, col) + c.boxChildren(4, row, col);
                        set(h, 'Position', [posX posY 0]);
                    end
                end
            end
        end
        
        function reset(c)
            for i = 1:numel(c.children)
                if ~isempty(c.children{i})
                    delete(c.children{i});
                end
            end
            
            c.boxChildren = [];
            c.children = {};
            c.nRows = 1;
            c.nCols = 1;
            c.gridInitialized = false;
        end
        
        function cmapRowNext = draw(c, cmap, cmapRowNext)
            % determine color for this grid
            color = cmap(mod(cmapRowNext-1, size(cmap, 1))+1, :);
            cmapRowNext = cmapRowNext + 1;
            
            % fill my inner box in a unique color
            drawBox(c.boxInner, 'none', color);
            
            if c.gridInitialized
                % draw grid boxes inside as white fill
                for row = 1:c.nRows
                    for col = 1:c.nCols
                        drawBox(c.boxChildren(:, row, col), 'none', 'w');
                    end
                end
                
                % draw children
                for row = 1:c.nRows
                    for col = 1:c.nCols
                        child = c.children{row, col};
                        if isempty(child)
                            continue;
                        elseif isa(child, 'MultiAxis.Container')
                            cmapRowNext = child.draw(cmap, cmapRowNext);
                        elseif isa(child, 'matlab.graphics.axis.Axes')
                            % draw the borders of the axis for debugging
                            % Position in green and OuterPosition in red
                            drawBox(get(child, 'OuterPosition'), 'none', [1 0.5 0.5]);
                            drawBox(get(child, 'Position'), 'none', [0.5 1 0.5]); 
                        end
                    end
                end
            end
            
            function drawBox(box, color, fillColor) 
                if nargin < 3
                    fillColor = 'none';
                end
                X = [box(1) box(1) box(1)+box(3) box(1)+box(3)];
                Y = [box(2) box(2)+box(4) box(2)+box(4) box(2)];
                patch(X, Y, 'k', 'Parent', c.ma.axhDraw, 'EdgeColor', color, ...
                    'FaceColor', fillColor, 'FaceAlpha', 0.5, ...
                    'HitTest', 'off');
            end
        end
    end
    
    methods % Configuration methods
        function grid(c, rows, cols, varargin)
            p = inputParser();
            p.addParameter('shareX', false, @islogical);
            p.addParameter('shareY', false, @islogical);
            p.parse(varargin{:});
            
            if c.gridInitialized
                error('Grid already initialized. Use reset()');
            end
            
            if isscalar(rows)
                c.nRows = rows;
                c.rowFrac = ones(rows, 1);
            else
                c.rowFrac = rows;
                c.nRows = numel(rows);
            end
            if isscalar(cols)
                c.nCols = cols;
                c.colFrac = ones(cols, 1);
            else
                c.colFrac = cols;
                c.nCols = numel(cols);
            end
            
            c.children = cell(c.nRows, c.nCols);
            c.boxChildren = nan(4, c.nRows, c.nCols);
            c.labels = MultiAxis.allocateHandleMatrix(c.nRows, c.nCols);
            c.shareX = p.Results.shareX;
            c.shareY = p.Results.shareY;
            c.linkRows = cell(c.nRows, 1);
            c.linkCols = cell(c.nCols, 1);
            c.gridInitialized = true;
        end
        
        function clear(c, row, col)
            if ~c.gridInitialized
                return;
            end
            
            if nargin < 3
                if c.nRows == 1 && c.nCols == 1
                    row = 1;
                    col = 1;
                else
                    error('Specify row, col');
                end
            end
            
            delete(c.children{row, col});
            c.children{row,col} = [];
            try delete(c.labels(row, col)); catch, end
            c.labels(row, col) = MultiAxis.getNullHandle();
            
            c.update();
        end
        
        function delete(c)
            c.reset();
            delete@handle(c);
        end
        
        function child = cell(c, row, col)
            % create or retrieve a child container at row, col
            if ~c.gridInitialized
                c.grid(1,1);
            end
            if nargin < 3
                if c.nRows == 1 && c.nCols == 1
                    row = 1;
                    col = 1;
                else
                    error('Specify row, col');
                end
            end
            
            child = c.children{row, col};
            if isempty(child)
                child = MultiAxis.Container(c, c.boxChildren(:, row, col));
            elseif isa(child, 'matlab.graphics.axis.Axes')
                error('An axis has already been created at this location');
            end
            
            % set this container as current
            c.ma.current = child;
            
            c.update();
        end
        
        function child = axis(c, row, col)
            c.ma.update();
            
            % create or retrieve a child axis at row, col
            if ~c.gridInitialized
                c.grid(1,1);
            end
            if nargin < 3
                if c.nRows == 1 && c.nCols == 1
                    row = 1;
                    col = 1;
                else
                    error('Specify row, col');
                end
            end
            
            child = c.children{row, col};
            if isempty(child)
                tag = MultiAxis.generateFigureUniqueTag(c.ma.figh, 'multiAxis');
                child = axes('Parent', c.ma.figh, 'OuterPosition', c.boxChildren(:, row, col), 'Color', 'none');
                set(child, 'Tag', tag);
                set(child, 'LooseInset', get(child, 'TightInset'));
                hold(child, 'on');
                c.children{row, col} = child;
            elseif isa(child, 'MultiAxis.Container')
                error('A child container has already been created at this location');
            end
        end
        
        function aa = autoAxis(c, row, col, varargin)
            % recover or install an AutoAxis on the axis attached at
            % row,col
            if ~c.gridInitialized
                c.grid(1,1);
            end
            if nargin < 3
                if c.nRows == 1 && c.nCols == 1
                    row = 1;
                    col = 1;
                else
                    error('Specify row, col');
                end
            end
            
            ax = c.axis(row, col);
            aa = AutoAxis.recoverForAxis(ax);
            if isempty(aa)
                aa = c.installConfigureAutoAxis(row, col, varargin{:});
            end
        end
        
        function h = label(c, row, col, varargin)
            if ~c.gridInitialized
                c.grid(1,1);
            end
            if nargin < 3
                if c.nRows == 1 && c.nCols == 1
                    row = 1;
                    col = 1;
                else
                    error('Specify row, col');
                end
            end
            
            h = c.labels(row, col);
            if numel(varargin) == 1
                str = varargin{1};
            else
                str = sprintf(varargin{:});
            end
            if MultiAxis.isValidHandle(h)
                set(h, 'String', str);
            else
                % place at top left corner
                posX = c.boxChildren(1, row, col);
                posY = c.boxChildren(2, row, col) + c.boxChildren(4, row, col);
                h = text(posX, posY, str, 'FontSize', c.ma.labelFontSize, ...
                    'Color', c.ma.labelFontColor, 'FontWeight', c.ma.labelFontWeight, ...
                    'Parent', c.ma.axhOverlay, 'HorizontalAlignment', 'left', ...
                    'VerticalAlignment', 'top');
                c.labels(row, col) = h;
            end
        end
            
        function aa = installConfigureAutoAxis(c, row, col, varargin)
            % install and reconfigure an auto-axis
            p = inputParser;
            p.addParameter('autoAxes', false, @islogical);
            p.addParameter('scaleBars', false, @islogical);
            p.parse(varargin{:});
            
            if ~c.gridInitialized
                c.grid(1,1);
            end
            if nargin < 3
                if c.nRows == 1 && c.nCols == 1
                    row = 1;
                    col = 1;
                else
                    error('Specify row, col');
                end
            end
            
            ax = c.axis(row, col);
            aa = AutoAxis(ax);
           
            aa.axisMargin = c.defaultMargins;
            
            if p.Results.scaleBars
                aa.reset();
                aa.addAutoScaleBarX();
                aa.addAutoScaleBarY();
            elseif p.Results.autoAxes
                aa.reset();
                aa.addAutoAxisX();
                aa.addAutoAxisY();
            end
            
            aa.installCallbacks();
        end
        
                
        function aaCell = installAutoAxes(c, varargin)
            if ~c.gridInitialized
                c.grid(1,1);
            end
            
            aaCell = cell(c.nRows, c.nCols);
            for row = 1:c.nRows
                for col = 1:c.nCols
                    child = c.children{row,col};
                    if isempty(child)
                        child = c.axis(row, col);
                    end
                    if isa(child, 'matlab.graphics.axis.Axes')
                        c.installConfigureAutoAxis(row, col, varargin{:});
                    end
                end
            end
        end
        
    end
    
    methods % Auto Axis and convenience layout configuration methods
        function axMat = collectAxes(c, mask)
            if ~c.gridInitialized
                c.grid(1,1);
            end
            
            if nargin < 2
                mask = true(c.nRows, c.nCols);
            end
            
            axMat = MultiAxis.allocateHandleMatrix(c.nRows, c.nCols);
            for row = 1:c.nRows
                for col = 1:c.nCols
                    if ~mask(row, col)
                        continue;
                    end
                    child = c.children{row, col};
                    if isa(child, 'matlab.graphics.axis.Axes')
                        axMat(row, col) = child;
                    end
                end
            end
        end
        
        function axCell = collectAxisColumn(c, col)
            mask = false(c.nRows, c.nCols);
            mask(:, col) = true;
            axCell = c.collectAxes(mask);
        end
        
        function axCell = collectAxisRow(c, row)
            mask = false(c.nRows, c.nCols);
            mask(row, :) = true;
            axCell = c.collectAxes(mask);
        end

        function aaCell = collectAutoAxes(c, mask)
            if ~c.gridInitialized
                c.grid(1,1);
            end
            
            if nargin < 2
                mask = true(c.nRows, c.nCols);
            end
            
            aaCell = cell(c.nRows, c.nCols);
            for row = 1:c.nRows
                for col = 1:c.nCols
                    if ~mask(row, col)
                        continue;
                    end
                    child = c.children{row, col};
                    if isa(child, 'matlab.graphics.axis.Axes')
                        aaCell{row, col} = AutoAxis.recoverForAxis(child);
                    end
                end
            end
        end
        
        function aa = topAutoAxis(c, col)
            child = c.children{1, col};
            if isa(child, 'matlab.graphics.axis.Axes')
                aa = AutoAxis(child);
            else
                aa = [];
            end
        end
        
        function aa = bottomAutoAxis(c, col)
            child = c.children{end, col};
            if isa(child, 'matlab.graphics.axis.Axes')
                aa = AutoAxis(child);
            else
                aa = [];
            end
        end
        
        function aaCell = collectAutoAxisColumn(c, col)
            mask = false(c.nRows, c.nCols);
            mask(:, col) = true;
            aaCell = c.collectAutoAxes(mask);
        end
        
        function aaCell = collectAutoAxisRow(c, row)
            mask = false(c.nRows, c.nCols);
            mask(row, :) = true;
            aaCell = c.collectAutoAxes(mask);
        end
        
        function columnSetMarginLeft(c, col, margin)
            aaCell = c.collectAutoAxisColumn(col);
            for i = 1:numel(aaCell)
                aaCell{i}.axisMarginLeft = margin;
            end
        end
        
        function columnSetMarginRight(c, col, margin)
            aaCell = c.collectAutoAxisColumn(col);
            for i = 1:numel(aaCell)
                aaCell{i}.axisMarginRight = margin;
            end
        end
        
        function rowSetMarginTop(c, row, margin)
            aaCell = c.collectAutoAxisRow(row);
            for i = 1:numel(aaCell)
                aaCell{i}.axisMarginTop = margin;
            end
        end
        
        function rowSetMarginBottom(c, row, margin)
            aaCell = c.collectAutoAxisRow(row);
            for i = 1:numel(aaCell)
                aaCell{i}.axisMarginBottom = margin;
            end
        end
        
        function rowYLabel(c, row, varargin)
            for iR = 1:numel(row)
                c.autoAxis(row(iR), 1).ylabel(varargin{:});
            end
        end
        
        function colXLabel(c, col, varargin)
            for iC = 1:numel(col)
                c.autoAxis(c.nRows, col(iC)).xlabel(varargin{:});
            end
        end
        
        function rowShareAxisY(c, row, varargin)
            % establishes a common axis for all AutoAxes in a row
            % sets margins, removes ylabels, and linkaxes. Doesn't add
            % anything to the first or last column, you'll need to add
            % scale bars and everything accordingly. You'll also need to
            % call update at the end.
            p = inputParser;
            p.addParameter('scaleBar', false, @islogical);
            p.addParameter('yUnits', '', @ischar);
            p.parse(varargin{:});
            scaleBar = p.Results.scaleBar;
            
            % default all rows
            if nargin < 2 || isempty(row)
                row = 1:c.nRows;
            end
            
            rowSet = row;
            
            aaCell = c.collectAutoAxisRow(row);
            for row = 1:c.nRows
                for col = 1:c.nCols
                    aa = aaCell{row,col};
                    if isempty(aa), continue; end
                    if scaleBar
                        aa.yUnits = p.Results.yUnits;
                        if col <= c.nCols
                            aa.clearY();
                            aa.axisMarginLeft = c.smallMargin;
                            aa.axisMarginRight = c.smallMargin;
                        else
                            % last column
                            aa.axisMarginLeft = c.smallMargin;
                            aa.axisMarginRight = c.defaultMargins(3);
                        end
                    else
                        % non scale bars
                        if col == 1
                            aa.axisMarginLeft = c.defaultMargins(1);
                            aa.axisMarginRight = c.smallMargin;
                            % aa.addAutoAxisY();
                        elseif col < c.nCols
                            aa.clearY();
                            aa.axisMarginLeft = c.smallMargin;
                            aa.axisMarginRight = c.smallMargin;
                        else
                            % last column
                            aa.clearY();
                            aa.axisMarginLeft = c.smallMargin;
                            aa.axisMarginRight = c.defaultMargins(3);
                        end
                    end
                end
                
                % done with row, linkaxes
                if ismember(row, rowSet)
                    ax = MultiAxis.filterValidHandles(c.collectAxisRow(row));
                    c.linkRows{row} = linkprop(ax, {'YLim', 'YDir'});
                end
            end
        end
        
        function colShareAxisX(c, col, varargin)
            % establishes a common axis for all AutoAxes in a column
            % sets margins, removes xlabels, and linkaxes. Doesn't add
            % anything to the first or last column, you'll need to add
            % scale bars and everything accordingly. You'll also need to
            % call update at the end.
            p = inputParser;
            p.addParameter('scaleBar', false, @islogical);
            p.addParameter('xUnits', '', @ischar);
            p.parse(varargin{:});
            
            % default all rows
            if nargin < 2 || isempty(col)
                col = 1:c.nCols;
            end
            
            colSet = col;
            
            aaCell = c.collectAutoAxisColumn(col);
            for col = 1:c.nCols
                for row = 1:c.nRows
                    aa = aaCell{row,col};
                    if isempty(aa), continue; end
                    aa.xUnits = p.Results.xUnits;
                    if row == 1
                        aa.clearX();
                        aa.axisMarginTop = c.defaultMargins(4);
                        aa.axisMarginBottom = c.smallMargin;
                    elseif row < c.nRows
                        aa.clearX();
                        aa.axisMarginTop = c.smallMargin;
                        aa.axisMarginBottom = c.smallMargin;
                    else
                        % last row
                        aa.axisMarginTop = c.smallMargin;
                        aa.axisMarginBottom = c.defaultMargins(2);
                    end
                end
                
                % done with col, linkaxes
                if ismember(col, colSet)
                    ax = MultiAxis.filterValidHandles(c.collectAxisColumn(col));
                    c.linkCols{col} = linkprop(ax, {'XLim', 'XDir'});
                end
            end
        end
        
    end
    
    methods(Static)
        function inset = getActualAxisInset(axh)
            outer = get(axh, 'OuterPosition');
            inner = get(axh, 'Position');
            dx = inner(1)-outer(1);
            dy = inner(2)-outer(2);
            dw = outer(3)-inner(3);
            dh = outer(4)-inner(4);
            inset = [dx, dy, dw-dx, dh-dy];
        end
        
        function inset = convertToNormalizedInset(inset, normToX, normToY)
            inset = [inset(1)/normToX, inset(2)/normToY, inset(3)/normToX, inset(4)/normToY];
        end
        
        function box = reduceBoxByInset(box, inset)
            box = [box(1)+inset(1) box(2)+inset(2) box(3)-inset(1)-inset(3) box(4)-inset(2)-inset(4)];
        end
        
        function box = expandBoxByInset(box, inset)
            box = [box(1)-inset(1) box(2)-inset(2) box(3)+inset(1)+inset(3) box(4)+inset(2)+inset(4)];
        end
    end
        
end
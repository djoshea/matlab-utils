classdef ThreeVector < handle
% This class draws three vectors in the lower right corner of an axis which
% indicate the orientation of the x, y, and z axes using a three pronged
% symbol. It installs callback methods to update these axes vectors when
% the plot is zoomed, rotated, panned, or resized. It also updates the
% vector labels when xlabel, ylabel, zlabel are set, or xlim, ylim, or zlim
% are changed.
%
%
% Usage:
%   tv = ThreeVector() % install for current axis
%   tv = ThreeVector(axh)
%       install for specific axis. if already installed,
%       returns the handle to the previously installed instance
% 
% Author: Dan O'Shea, {my first name} AT djoshea DOT com (c) 2014
%
% NOTE: This class graciously utilizes code from the following authors:
%
% MinLong Kwong: For computing the data to figure space coordinate 
%   transformation matrix.
%   http://www.mathworks.com/matlabcentral/fileexchange/43896
%
% Malcolm Lidierth: For the isMultipleCall utility to prevent callback
%   re-entrancy
%   http://undocumentedmatlab.com/blog/controlling-callback-re-entrancy/
%

    properties
        axisInset = [0.3 0.3]; % in cm [left bottom]
        vectorLength = 2; % in cm
        
        fontSize % font size used for axis labels
        fontColor % font color used for axis labels
        lineWidth % line width used for axis vectors
        lineColor % line color used for axis vectors
    end
    
    properties(SetAccess=protected)
        axh % handle of axis to control
        
        figToData % transformation matrix figure -> data
        dataToFig % transformation matrix data -> figure
        cornerData % x/y/z by bottomLeft/topRight matrix in data coordinates of visual axis corners
        
        hv % handles to x,y,z vectors
        ht % handles to x,y,z text labels
        
        handleTags % information used to recover handles when saving
    end
    
    methods
        function tv = ThreeVector(axh)
            % auto-recover the existing instance if associated with axis
            % axh, otherwise create a new one
            if nargin < 1 || isempty(axh)
                axh = gca;
            end
            
            tv = ThreeVector.createOrRecoverInstance(tv, axh);
        end        
        
        function update(tv)
            % reposition and redraw all ThreeVector annotations for axis
            
            axh = tv.axh; %#ok<*PROP>
            axis(axh, 'vis3d'); % this is evidently important for ensuring that all vectors stay visible
            
            % get data to paper conversion
            set(axh, 'Units', 'centimeters');
            posPaper = get(axh, 'Position');
            set(axh, 'Units', 'normalized');
            posNorm = get(axh, 'Position');

            xUnitsToNorm = posNorm(3)/posPaper(3);
            yUnitsToNorm = posNorm(4)/posPaper(4);
            
            % get data to points conversion
            tv.updateTransforms();

            %set(axh, 'OuterPosition', [0.1 0.1 0.8 0.8]);
            outerPos = get(axh, 'OuterPosition');

            % size of three vector box in axis units
            offsetY = tv.axisInset(2) * yUnitsToNorm;
            offsetX = tv.axisInset(1) * xUnitsToNorm;
            vectorLength = tv.vectorLength * xUnitsToNorm;

            % convert the lower left corner of the figure to data
            % coordinates
            cornerFig = [outerPos(1)+offsetX; outerPos(2)+offsetY; 0];
            cornerData = tv.convertFigToData(cornerFig);
            sX = 1;
            sY = 1;
            sZ = 1;
            vecAx = [sX, 0, 0; 0 sY 0; 0 0 sZ];
            ends = [cornerData+vecAx(:, 1), cornerData+vecAx(:, 2), cornerData+vecAx(:, 3)];
            % ends is x,y,z,1 coordinates (rows) for x axis, y axis, z axis endpoints (cols)

            allPointsData = [cornerData, ends];
            allPointsFig = tv.convertDataToFig(allPointsData);
            
            %allPointsFig(:, 3) = 0;
           
            corner = allPointsFig(:, 1);
            endX = allPointsFig(:, 2);
            endY = allPointsFig(:, 3);
            endZ = allPointsFig(:, 4);
            
            % normalize vector lengths in figure units
            endX = corner + (endX-corner) ./ norm(endX-corner) * vectorLength;
            endY = corner + (endY-corner) ./ norm(endY-corner) * vectorLength;
            endZ = corner + (endZ-corner) ./ norm(endZ-corner) * vectorLength;
            
            % position the text boxes slightly further away
            endXText = corner + (endX-corner) ./ norm(endX-corner) * vectorLength * 1.2;
            endYText = corner + (endY-corner) ./ norm(endY-corner) * vectorLength * 1.2;
            endZText = corner + (endZ-corner) ./ norm(endZ-corner) * vectorLength * 1.2;
            
            allPointsFig = [corner endX endY endZ endXText endYText endZText];
            
            % might need to play with this value. Set too high and opengl
            % will clip it, set too low and data will cover up the
            % annotations.
            allPointsFig(3, :) = 0.3;
            
            % translate the axis indicators to avoid leaving the outer position box
            xMin = min(allPointsFig(1, :));
            if xMin < outerPos(1) + offsetX
                allPointsFig(1, :) = allPointsFig(1, :) + outerPos(1) + offsetX - xMin;
            end
            yMin = min(allPointsFig(2, :));
            if yMin < outerPos(2) + offsetY
                allPointsFig(2, :) = allPointsFig(2, :) + outerPos(2) + offsetY  - yMin;
            end

            %allPointsFig(3, :) = allPointsFig(3, :) + 10;
            
            allPoints = tv.convertFigToData(allPointsFig);

            corner = allPoints(:, 1);
            endX = allPoints(:, 2);
            endY = allPoints(:, 3);
            endZ = allPoints(:, 4);
            endXText = allPoints(:, 5);
            endYText = allPoints(:, 6);
            endZText = allPoints(:, 7);
            
            % update vectors
            set(tv.hv, 'XLimInclude', 'off', 'YLimInclude', 'off', ...
                'ZLimInclude', 'off', 'Clipping', 'off', 'Color', tv.lineColor);
            set(tv.hv(1), 'XData', [corner(1) endX(1)], ...
                'YData', [corner(2) endX(2)], 'ZData', [corner(3) endX(3)]);
            set(tv.hv(2), 'XData', [corner(1) endY(1)], ...
                'YData', [corner(2) endY(2)], 'ZData', [corner(3) endY(3)]);
            set(tv.hv(3), 'XData', [corner(1) endZ(1)], ...
                'YData', [corner(2) endZ(2)], 'ZData', [corner(3) endZ(3)]);
            set(tv.hv, 'LineWidth', tv.lineWidth);
            
            % update text label positions
            set(tv.ht(1), 'Position', endXText(1:3)');
            set(tv.ht(2), 'Position', endYText(1:3)');
            set(tv.ht(3), 'Position', endZText(1:3)');
            
            % update text label contents
            set(tv.ht(1), 'String', get(get(axh, 'XLabel'), 'String'));
            set(tv.ht(2), 'String', get(get(axh, 'YLabel'), 'String'));
            set(tv.ht(3), 'String', get(get(axh, 'ZLabel'), 'String'));
            
            set(tv.ht, 'Clipping', 'off', 'FontSize', tv.fontSize, 'Color', tv.fontColor, ...
                'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Middle');
            
            set(tv.ht, 'Visible', 'on');
            set(tv.hv, 'Visible', 'on');
        end
    end
    
    methods(Static, Access=protected)
        function tv = createOrRecoverInstance(tv, axh)
            % if an instance is stored in this axis' UserData.autoAxis
            % then return the existing instance, otherwise create a new one
            % and install it
            
            tvTest = ThreeVector.recoverForAxis(axh);
            if isempty(tvTest)
                % not installed, create and install new instance
                tv.initializeNewInstance(axh);
                tv.installInstanceForAxis(axh);
            else
                % return the existing instance
                tv = tvTest;
            end
        end
        
         function [tvCell, hAxes] = recoverForFigure(figh)
            % recover the AutoAxis instances associated with all axes in
            % figure handle figh
            if nargin < 1, figh = gcf; end
            hAxes = findobj(figh, 'Type', 'axes');
            tvCell = cell(numel(hAxes), 1);
            for i = 1:numel(hAxes)
                tvCell{i} = ThreeVector.recoverForAxis(hAxes(i));
            end
            
            mask = ~cellfun(@isempty, tvCell);
            tvCell = tvCell(mask);
            hAxes = hAxes(mask);
        end
        
        function ax = recoverForAxis(axh)
            % recover the AutoAxis instance associated with the axis handle
            % axh
            if nargin < 1, axh = gca; end
            ud = get(axh, 'UserData');
            if isempty(ud) || ~isstruct(ud) || ~isfield(ud, 'threeVector')
                ax = [];
            else
                ax = ud.threeVector;
            end
        end
        
        function hideInLegend(h)
            % prevent object h from appearing in legend by default
            for i = 1:numel(h)
                ann = get(h(i), 'Annotation');
                leg = get(ann, 'LegendInformation');
                set(leg, 'IconDisplayStyle', 'off');
            end
        end
        
        function figureCallback(figh, varargin)
            % update all axes with installed ThreeVectors in a figure
            if ThreeVector.isMultipleCall(), return, end;
            ThreeVector.updateFigure(figh);
        end
             
        function preUpdateCallback(varargin)
            % callback called before update
            if ThreeVector.isMultipleCall(), return, end;
            if isfield(varargin{2}, 'Axes')
                axh = varargin{2}.Axes;
                tv = ThreeVector.recoverForAxis(axh);
                set(tv.ht, 'Visible', 'off');
                set(tv.hv, 'Visible', 'off');
            end
        end
        
        function axisCallback(varargin)
            % callback called on specific axis
            if ThreeVector.isMultipleCall(), return, end;
            if isfield(varargin{2}, 'Axes')
                axh = varargin{2}.Axes;
                tv = ThreeVector.recoverForAxis(axh);
                tv.updateAxh(axh);
                tv.update();
            end
        end
        
         function updateFigure(figh)
            % call update for every managed axis in a figure
            if nargin < 1, figh = gcf; end
            [tvCell, hAxes] = ThreeVector.recoverForFigure(figh);
            for i = 1:numel(tvCell)
                % we pass along the axis handle so that the update method
                % can appropriately update it's internal axis handle when
                % save/load has occurred
                tvCell{i}.updateAxh(hAxes(i));
                tvCell{i}.update();
            end
        end
        
        function fig = getParentFigure(axh)
            % if the object is a figure or figure descendent, return the
            % figure. Otherwise return [].
            fig = axh;
            while ~isempty(fig) && ~strcmp('figure', get(fig,'type'))
              fig = get(fig,'parent');
            end
        end
        
        function flag = isMultipleCall()
            % returns true if this callback has been called in a nested
            % fashion, which can help to avoid reentrancy.
            % Copied from Malcolm Lidierth's utility
            % http://undocumentedmatlab.com/blog/controlling-callback-re-entrancy/
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
    end
    
    methods(Access=protected)
        function installInstanceForAxis(tv, axh)
            % store instance in UserData
            ud = get(axh, 'UserData');
            if ~isstruct(ud)
                ud = struct('threeVector', tv);
            else
                ud.autoAxis = tv;
            end
            set(axh, 'UserData', ud);
         end
        
        function initializeNewInstance(tv, axh)
            % set property values for new instance
            tv.axh = axh;
            tv.fontSize = get(0, 'DefaultAxesFontSize');
            tv.lineWidth = 2;
            tv.fontColor = [0.1 0.1 0.1];
            tv.lineColor = [0.4 0.4 0.4];
            
            tv.initialize();
            tv.update();
            tv.installCallbacks();
        end
        
        function initialize(tv)
            % draw the axis vectors and the text labels
            if ~isempty(tv.hv)
                delete(tv.hv);
            end
            tv.hv(1) = plot3([0 1], [0 1], [0 1], '-', 'LineSmoothing', 'on', 'Parent', tv.axh);
            tv.hv(2) = plot3([0 1], [0 1], [0 1], '-', 'LineSmoothing', 'on', 'Parent', tv.axh);
            tv.hv(3) = plot3([0 1], [0 1], [0 1], '-', 'LineSmoothing', 'on', 'Parent', tv.axh);

            if ~isempty(tv.ht)
                delete(tv.ht);
            end
            
            tv.ht(1) = text(0, 1, 'X', 'HorizontalAlign', 'Left', 'Parent', tv.axh);
            tv.ht(2) = text(0, 2, 'Y', 'HorizontalAlign', 'Left', 'Parent', tv.axh);
            tv.ht(3) = text(0, 3, 'Z', 'HorizontalAlign', 'Left', 'Parent', tv.axh);
            
            ThreeVector.hideInLegend(tv.hv);
            ThreeVector.hideInLegend(tv.ht);
            
            % tag handles so that they can be recovered on save/load
            handleStruct.hv = tv.hv;
            handleStruct.ht = tv.ht;
            tv.tagHandlesForRecovery(handleStruct);
        end
        
        function reinstallPostLoad(tv)
            % recover handles via tags, and reinstall callbacks
            
            h = tv.recoverTaggedHandles();
            tv.hv = h.hv;
            tv.ht = h.ht;
            
            tv.installInstanceForAxis(tv.axh);
            tv.installCallbacks();
        end
        
        function updateAxh(tv, axh)
            % update the internal axis handle .axh when called from callback
            % recovering handles and reinstalling callbacks if necessary
            
            if tv.axh ~= axh
                % new handles being used, recover everything
                tv.axh = axh;
                tv.reinstallPostLoad();
            end
        end
        
        function installCallbacks(tv)
            % install update callbacks for zoom, pan, rotate, resize, x/y/z
            % label changes, x/y/z lims changes
            figh = ThreeVector.getParentFigure(tv.axh);
            
            set(zoom(tv.axh),'ActionPreCallback',@ThreeVector.preUpdateCallback);
            set(zoom(tv.axh),'ActionPostCallback',@ThreeVector.axisCallback);
            
            set(pan(figh),'ActionPreCallback',@ThreeVector.preUpdateCallback);
            set(pan(figh),'ActionPostCallback',@ThreeVector.axisCallback);
            set(figh, 'ResizeFcn', @ThreeVector.figureCallback);
            
            set(rotate3d(tv.axh),'ActionPreCallback',@ThreeVector.preUpdateCallback);
            set(rotate3d(tv.axh), 'ActionPostCallback', @ThreeVector.axisCallback);
            
            addlistener(tv.axh, {'XLim', 'YLim', 'ZLim'}, 'PostSet', @tv.localCallback);
            addlistener(get(tv.axh, 'XLabel'), 'String', 'PostSet', @tv.localCallback);
            addlistener(get(tv.axh, 'YLabel'), 'String', 'PostSet', @tv.localCallback);
            addlistener(get(tv.axh, 'ZLabel'), 'String', 'PostSet', @tv.localCallback);
        end
        
        function localCallback(tv, varargin)
            % perform an update. This method must be called with the
            % correct ThreeVector instance, whereas
            % ThreeVector.axisCallback will automatically find the right
            % ThreeVector instance for the active axis.
            
            if ThreeVector.isMultipleCall(), return, end;
            tv.update();
        end
        
        function tagHandlesForRecovery(tv, s)
            % for each field in s, for each element j in s.field, set 'Tag'
            % on that handle to be 'field__j' and store 'field__j' as
            % tv.handleTags.field{j}. This is used by recoverTaggedHandles
            % to repopulate stored handles upon figure loading or copying
            
            flds = fieldnames(s);
            for iField = 1:numel(flds)
                f = flds{iField};
                tv.handleTags.(f) = cell(numel(s.(f)), 1);
                for j = 1:numel(s.(f))
                    str = sprintf('%s__%d', f, j);
                    tv.handleTags.(f){j} = str;
                    set(s.(f)(j), 'Tag', str);
                end
            end
        end
        
        function h = recoverTaggedHandles(tv)
            % for each field in handleTags, for each element in
            % handleTags.field{j}, find the handle graphics object with tag
            % 'field__j' and store the handle of that object in h.field(j)
            
            flds = fieldnames(tv.handleTags);
            for iField = 1:numel(flds)
                f = flds{iField};
                h.(f) = nan(numel(tv.handleTags.(f)), 1);
                for j = 1:numel(tv.handleTags.(f))
                    tag = tv.handleTags.(f){j};
                    val = findobj(tv.axh, 'Tag', tag);
                    if isempty(val)
                        warning('Could not recover tagged handle %s', tag);
                    end
                    h.(f)(j) = val;
                end
            end
        end
    end
    
    methods % methods for computing positions of annotations
        
        function ptsData = convertFigToData(tv, ptsFig)
             % ptsFig, ptsData are 3 x N matrices
             % row 1 is X, row 2 is Y, row 3 is Z
             ptsFig = [ptsFig; ones(1, size(ptsFig, 2))];
             ptsData = tv.figToData * ptsFig;
             ptsData = bsxfun(@rdivide, ptsData, ptsData(4, :));
             ptsData = ptsData(1:3, :);
        end
        
        function ptsFig = convertDataToFig(tv, ptsData)
            % ptsFig, ptsData are 3 x N matrices
            % row 1 is X, row 2 is Y, row 3 is Z
            ptsData = [ptsData; ones(1, size(ptsData, 2))];
            ptsFig = tv.dataToFig * ptsData;
            ptsFig = bsxfun(@rdivide, ptsFig, ptsFig(4, :));
            ptsFig = ptsFig(1:3, :);
        end
        
        function updateTransforms(tv)
            % compute data <-> normalized coordinate transforms
            tv.dataToFig = tv.getDataToFigureCoordinateTransform();
            tv.figToData = tv.dataToFig^-1;
        end

        function matrixTransform = getDataToFigureCoordinateTransform(tv)
            % get transform matrix which transform axes coordinate to figure coordinate
            %
            % NOTE: This function is essentially copied verbatim from
            % MinLong Kwong's File Exchange submission found here:
            % http://www.mathworks.com/matlabcentral/fileexchange/43896-3d-data-space-coordinates-to-normalized-figure-coordinates-conversion/content/ds2fig.m
            
            hAxes = tv.axh;
            matrixTransform = [];

            %%%% obtain data needed
            % camera
            viewAngle = get(hAxes, 'CameraViewAngle');
            viewTarget = get(hAxes, 'CameraTarget');
            viewPosition = get(hAxes, 'CameraPosition');
            viewUp = get(hAxes, 'CameraUpVector');
            % axes direction
            axesDirection = strcmp(get(hAxes, {'XDir', 'YDir', 'ZDir'}), 'normal');
            % data scale
            dataZLim = get(hAxes, 'ZLim');
            dataRatio = get(hAxes, 'DataAspectRatio');
            if any(dataRatio == 0), return, end
            plotBoxRatio = get(hAxes, 'PlotBoxAspectRatio');
            if any(plotBoxRatio == 0), return, end
            % is perspective
            isPerspective = strcmp(get(hAxes, 'Projection'), 'perspective');
            % axes position
            axesUnitsOriginal = get(hAxes, 'Units');
            set(hAxes, 'Units', 'normalized'); 
            positionNormal = get(hAxes, 'Position');
            set(hAxes, 'Units', 'pixels'); 
            positionPixel = get(hAxes, 'Position');
            set(hAxes, 'Units', axesUnitsOriginal);
            % stretch
            stretchMode = strcmp(get(hAxes, {'CameraViewAngleMode', ...
                'DataAspectRatioMode', 'PlotBoxAspectRatioMode'}), 'auto');
            stretchToFill = all(stretchMode);
            stretchToFit = ~stretchToFill && stretchMode(1);
            stretchNone = ~stretchToFill && ~stretchToFit;

            %%%% model view matrix
            % move data space center to viewTarget point
            matrixTranslate = eye(4);
            matrixTranslate(1:3, 4) = -viewTarget;
            % rescale data
            % note: matlab will rescale data space by dividing DataAspectRatio
            %       and normalize z direction to 1 to makeup the 'PlotBox'
            scaleFactor = dataRatio / dataRatio(3) * (dataZLim(2) - dataZLim(1));
            scaleDirection = axesDirection * 2 - 1;
            matrixRescale = diag([scaleDirection ./ scaleFactor, 1]);
            % rotate the 'PlotBox'
            vecticesZUp = matrixRescale * ...
                [matrixTranslate * [viewPosition, 1]', [viewUp, 1]'];
            zVector = vecticesZUp(1:3, 1);
            upVector = vecticesZUp(1:3, 2);
            viewDistance = sqrt(dot(zVector, zVector));
            zDirection = zVector / viewDistance;
            yVector = upVector - zDirection * dot(zDirection, upVector);
            yDirection = yVector / sqrt(dot(yVector, yVector));
            matrixRotate = blkdiag( ...
                [cross(yDirection, zDirection), yDirection, zDirection]', 1);

            %%%% projection matrix
            % note: matlab will project the rotated 'PlotBox' to an area of 
            %       [-0.5, 0.5; -0.5, 0.5]
            matrixProjection = eye(4);
            matrixProjection(4, 3) = -isPerspective / viewDistance;
            projectionArea = 2 * tan(viewAngle * pi / 360) * viewDistance;
            matrixProjection = diag([ones(1, 3), projectionArea]) * matrixProjection;

            %%%% stretch matrix
            % stretch the projective 'PlotBox' into the position retangle of the axes
            % note: stretch will first detect data region
            if stretchToFill || stretchToFit
                plotBox = [0 0 0; 0 0 1; 0 1 0; 0 1 1; 1 0 0; 1 0 1; 1 1 0; 1 1 1]' - .5;
                plotBox = diag(plotBoxRatio / plotBoxRatio(3)) * plotBox;
                edgeVertices = matrixProjection * matrixRotate * [plotBox; ones(1, 8)];
                edgeVertices(1, :) = edgeVertices(1, :) ./ edgeVertices(4, :);
                edgeVertices(2, :) = edgeVertices(2, :) ./ edgeVertices(4, :);
                edgeVertices = edgeVertices(1:2, :)';
                % note: the low boundary and the high boundary of data region may be
                %       difference in perspective projection, so the figure should move
                %       to center, but here no need to do so, because matlab ignore it
                dataRegion = max(edgeVertices) - min(edgeVertices);
                % note: matlab have a strange addition stretch in stretch to fit mode.
                %       one side of the data region will hit the position rectangle,
                %       and matlab will assume data region of that side to be 1 keeping
                %       aspect ratio.
                if stretchToFit
                    strangeFactor = dataRegion ./ positionPixel(3:4);
                    if strangeFactor(1) > strangeFactor(2)
                        dataRegion = dataRegion / dataRegion(1);
                    else
                        dataRegion = dataRegion / dataRegion(2);
                    end
                end
            else
                % note: if no stretch, it will use projection area as data region
                dataRegion = [1, 1];
            end
            % note: stretch than apply a stretchFactor to the data, such that it fit
            %       in the axes position retangle
            if stretchToFit || stretchNone
                stretchFactor = dataRegion ./ positionPixel(3:4);
                stretchFactor = stretchFactor / max(stretchFactor);
            else
                stretchFactor = [1, 1];
            end
            matrixStretch = diag([stretchFactor ./ dataRegion, 1, 1]);

            %%%% view port matrix
            matrixViewPort = diag([positionNormal(3:4), 1, 1]);
            matrixViewPort(1:2, 4) = positionNormal(1:2) + positionNormal(3:4) / 2;

            %%%% return transformation matrix
            matrixTransform = matrixViewPort * matrixStretch * matrixProjection * ...
                matrixRotate * matrixRescale * matrixTranslate;
        end
        
    end
end




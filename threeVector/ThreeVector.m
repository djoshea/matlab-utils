classdef ThreeVector < handle
% This class draws three vectors in the lower right corner of an axis which
% indicate the orientation of the x, y, and z axes using a three pronged
% symbol. It installs callback methods to update these axes vectors when
% the plot is zoomed, rotated, panned, etc.
% 
% Author: Dan O'Shea, {my first name} AT djoshea DOT com (c) 2014
%
% NOTE: This class utilizes code for computing the data to figure space
% coordinate transformation matrix, which was authored by
% MinLong Kwong. This file Exchange submission is found here:
% http://www.mathworks.com/matlabcentral/fileexchange/43896

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
    end
    
    methods(Static)
        function tv = createOrRecoverInstance(tv, axh)
            % if an instance is stored in this axis' UserData.threeVector
            % then return the existing instance, otherwise create a new one
            % and install it
            
            ud = get(axh, 'UserData');
            if isempty(ud) || ~isstruct(ud) || ~isfield(ud, 'threeVector') || isempty(ud.threeVector)
                tv.initializeNewInstance(axh);
                if ~isstruct(ud)
                    ud = struct('threeVector', tv);
                else
                    ud.threeVector = tv;
                end
                set(axh, 'UserData', ud);
            else
                % return the existing instance
                tv = ud.threeVector;
            end
        end
    end
    
    methods    
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
            tv.hv(1) = plot3([0 1], [0 1], [0 1], '-');
            tv.hv(2) = plot3([0 1], [0 1], [0 1], '-');
            tv.hv(3) = plot3([0 1], [0 1], [0 1], '-');

            if ~isempty(tv.ht)
                delete(tv.ht);
            end
            
            tv.ht(1) = text(0, 1, 'X', 'HorizontalAlign', 'Left');
            tv.ht(2) = text(0, 2, 'Y', 'HorizontalAlign', 'Left');
            tv.ht(3) = text(0, 3, 'Z', 'HorizontalAlign', 'Left');
        end
        
        function update(tv)
            % update the position and orientation of all axis vectors
            
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

            cornerFig = [outerPos(1)+offsetX; outerPos(2)+offsetY; 0];
            cornerData = tv.convertFigToData(cornerFig);
            sX = 1;
            sY = 1;
            sZ = 1;
            vecAx = [sX, 0, 0; 0 sY 0; 0 0 sZ];
            ends = [cornerData+vecAx(:, 1), cornerData+vecAx(:, 2), cornerData+vecAx(:, 3)];
            % ends is x,y,z,1 coordinates (rows) for x axis, y axis, z axis endpoints (cols)

            % translate the axis indicators to avoid leaving the outer position box
            allPointsData = [cornerData, ends];
            allPointsFig = tv.convertDataToFig(allPointsData);
           
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
            
            % offset the 
            xMin = min(allPointsFig(1, :));
            if xMin < outerPos(1) + offsetX
                allPointsFig(1, :) = allPointsFig(1, :) + outerPos(1) + offsetX - xMin;
            end
            yMin = min(allPointsFig(2, :));
            if yMin < outerPos(2) + offsetY
                allPointsFig(2, :) = allPointsFig(2, :) + outerPos(2) + offsetY  - yMin;
            end

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
    
    methods % update callback logic
        function installCallbacks(tv)
%             lh(1) = addlistener(ax.axh, {'XLim', 'YLim'}, ...
%                 'PostSet', @ax.updateLimsCallback);
            figh = tv.getParentFigure();
            set(zoom(tv.axh),'ActionPreCallback',@tv.preUpdateCallback);
            set(zoom(tv.axh),'ActionPostCallback',@tv.updateCallback);
            
            set(pan(figh),'ActionPreCallback',@tv.preUpdateCallback);
            set(pan(figh),'ActionPostCallback',@tv.updateCallback);
            set(figh, 'ResizeFcn', @tv.updateCallback);
            
            set(rotate3d(tv.axh),'ActionPreCallback',@tv.preUpdateCallback);
            set(rotate3d(tv.axh), 'ActionPostCallback', @tv.updateCallback);
            %addlistener(ax.axh, 'Position', 'PostSet', @ax.updateFigSizeCallback);
        end
        
        function preUpdateCallback(tv, varargin)
            set(tv.ht, 'Visible', 'off');
            set(tv.hv, 'Visible', 'off');
        end
        
        function fig = getParentFigure(tv)
            % if the object is a figure or figure descendent, return the
            % figure. Otherwise return [].
            fig = tv.axh;
            while ~isempty(fig) && ~strcmp('figure', get(fig,'type'))
              fig = get(fig,'parent');
            end
        end

        function updateCallback(tv, varargin)
            if tv.isMultipleCall(), return, end;
            tv.update();
        end
        
        function flag = isMultipleCall(tv) %#ok<MANU>
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
end




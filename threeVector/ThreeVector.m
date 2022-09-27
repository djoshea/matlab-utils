classdef ThreeVector < handle
% This class draws three vectors in the lower, left corner of an axis which
% indicate the orientation of the x, y, and z axes using a three pronged
% symbol. The ends of the vectors are labeled according to the axis xlabel,
% ylabel, zlabel. It installs callback methods to update these axes vectors 
% when the plot is zoomed, rotated, panned, or resized. It also updates the
% vector labels when xlabel, ylabel, zlabel are set, or xlim, ylim, or zlim
% are changed. ThreeVector also deals gracefully with figure save and load
% by appropriatelyf finding and updating internal graphics objects handles
% on load.
%
% Usage:
%
%   tv = ThreeVector() 
%       install for current axis
% 
%   tv = ThreeVector(axh)
%       install for specific axis. if already installed,
%       returns the handle to the previously installed instance after
%       calling update()
%
%   tv.update() 
%       force an update on the axis associated with tv
%
%   ThreeVector.updateFigure(figh [== gcf])
%       update all axes with ThreeVector installed within figure figh.
%
%   ThreeVector.updateAxes(axh [== gca])
%       update axis axh if ThreeVector installed
%
%   ThreeVector.demo()
%       plot a demo surface and install ThreeVector
%
%   Properties: setting these will automatically result in an update()
%
%        fontSize  : font size used for axis labels, defaults to get(axh, 'FontSize')
%
%        fontColor : 3 x 1 color vector or plot-color-string (e.g. 'k')
%          used to label axes, defaults to 0.1 gray
%
%        lineWidth : line width used for axis vectors
%
%        lineColor : 3 x 1 color vector or plot-color-string (e.g. 'k') for
%          axis vector lines, defaults to 0.4 gray
%
%        vectorLength : scalar length of all axis vectors in cm
%
%        textVectorNormalizedPosition : position of axis labels along vectors
%          in units normalized to the vector length. E.g. 1 is end of vector, 
%          0.5 is halfway along vector, 1.5 is 1.5 times the length of the vector.
%
%        axisInset: 2 x 1 vector of offsets in cm from bottom left corner.
%          in the form [offsetFromLeft, offsetFromBottom]
% 
% Author: Dan O'Shea, {my first name} AT djoshea.com (c) 2014
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
        hideAxes logical = true;
        niceGrid logical = false;
        axisInset = [0.2 0.2]; % in cm [left bottom]
        vectorLength = 1; % in cm

        enableUpdates = true;
        
        flipAxis = [false false false];
        
        % position of axis labels along vectors in units normalized to the
        % vector length. 1 is end of vector, 0.5 is halfway along vector, 
        % 1.5 is 1.5 times the length of the vector.
        textVectorNormalizedPosition = 1.3; 
        textMargin = 0.01;
        
        fontSize % font size used for axis labels
        fontColor % font color used for axis labels
        lineWidth % line width used for axis vectors
        lineColor % line color used for axis vectors
        
        labelHorizontalAlignment (3, 1) string = ["center"; "center"; "center"];
        labelVerticalAlignment (3, 1) string = ["middle"; "middle"; "middle"];
        
        background = false;
        backgroundColor = [1 1 1];
        backgroundAlpha = 0.3;
        backgroundMargin = 0.2;
        
        useCallbacks = true;
        
        positionFrozen = false;
        positionFrozenCorner
        
        interpreter (1, 1) string = "none";
    end
    
    properties(SetAccess=protected)
        axh % handle of axis to control
        
        axhOverlay % handle of axis to use as overlay
    end
    
    properties(Hidden, SetAccess=protected)
        axhOverlayTag % tag used to find axhOverlay in figure
        
        figToData % transformation matrix figure -> data
        dataToFig % transformation matrix data -> figure
        cornerData % x/y/z by bottomLeft/topRight matrix in data coordinates of visual axis corners
        
        hv % handles to x,y,z vectors
        ht % handles to x,y,z text labels
        hback % background rectangle
        
        handleTags % information used to recover handles when saving
        
        hListenerTemp
    end
    
    methods
        function tv = ThreeVector(axh, varargin)
            p = inputParser();
            p.addParameter('useCallbacks', true, @islogical);
            p.addParameter('hideAxes', true, @islogical);
            p.addParameter('niceGrid', false, @islogical);
            p.parse(varargin{:});
            
            % auto-recover the existing instance if associated with axis
            % axh, otherwise create a new one
            if nargin < 1 || isempty(axh)
                axh = gca;
            end
            tv.useCallbacks = p.Results.useCallbacks;
            tv.hideAxes = p.Results.hideAxes;
            tv.niceGrid = p.Results.niceGrid;
            
            tv = ThreeVector.createOrRecoverInstance(tv, axh);
            tv.update();
        end        
        
        function update(tv)
            % reposition and redraw all ThreeVector annotations for axis
            
            if ~tv.enableUpdates
                return
            end
            axh = tv.axh; %#ok<*PROP>
            axhOverlay = tv.axhOverlay;
            if isempty(axh) || ~ishandle(axh) || (~isempty(axhOverlay) && ~ishandle(axhOverlay))
                delete(tv);
                return;
            end
            if isempty(axh) || isempty(axhOverlay) || ~ishandle(axhOverlay), return, end
            
            if ~ishandle(tv.ht)
                tv.reinstallPostLoad();
            end
            
            % update the position of the overlay axis
            %pos = get(axh, 'OuterPosition');
            [pos, ~, posPaper] = tv.getTrueAxesPosition(true); % get outer position
            set(axhOverlay, 'Units', 'normalized', 'Position', pos);
            axis(axhOverlay, [pos(1) pos(1)+pos(3) pos(2) pos(2)+pos(4)]);
            
            % get data to paper conversion
%             set(axhOverlay,  'Units', 'centimeters');
%             posPaper = get(axhOverlay, 'Position');
%             set(axhOverlay, 'Units', 'normalized');
            
            axis(axhOverlay, 'off');
            set(axhOverlay, 'Color', 'none', 'HitTest', 'off');

            xUnitsToNorm = pos(3) / posPaper(3);
            yUnitsToNorm = pos(4) / posPaper(4);
            zUnitsToNorm = (xUnitsToNorm + yUnitsToNorm) / 2;
            
            % get data to points conversion
            tv.updateTransforms();

            %daspect(tv.axhOverlay, [1 1 1]);
            
            % size of three vector box in axis units
            offsetY = tv.axisInset(2) * yUnitsToNorm;
            offsetX = tv.axisInset(1) * xUnitsToNorm;
            
            % build out the three vectors in data coordinates
            cornerData = [0;0;0];
            
            if tv.flipAxis(1), sX = -1; else, sX = 1; end
            if tv.flipAxis(2), sY = -1; else, sY = 1; end
            if tv.flipAxis(3), sZ = -1; else, sZ = 1; end
            
            vecAx = [sX, 0, 0; 0 sY 0; 0 0 sZ];
            ends = [cornerData+vecAx(:, 1), cornerData+vecAx(:, 2), cornerData+vecAx(:, 3)];
            % ends is x,y,z,1 coordinates (rows) for x axis, y axis, z axis endpoints (cols)
            allPointsData = [cornerData, ends];
            
            % convert back to figure coordinates
            allPointsFig = tv.convertDataToFig(allPointsData);
           
            % then convert to paper units
            allPointsFigNorm = allPointsFig;
            allPointsFigNorm(1, :) = allPointsFigNorm(1, :) / xUnitsToNorm;
            allPointsFigNorm(2, :) = allPointsFigNorm(2, :) / yUnitsToNorm;
            allPointsFigNorm(3, :) = allPointsFigNorm(3, :) / zUnitsToNorm;
            corner = allPointsFigNorm(:, 1);
            endX = allPointsFigNorm(:, 2);
            endY = allPointsFigNorm(:, 3);
            endZ = allPointsFigNorm(:, 4);
            
            % normalize each vectors lengths in figure units
            endX = corner + (endX-corner) ./ norm(endX-corner) * tv.vectorLength;
            endY = corner + (endY-corner) ./ norm(endY-corner) * tv.vectorLength;
            endZ = corner + (endZ-corner) ./ norm(endZ-corner) * tv.vectorLength;
            
            % position the text boxes slightly further away
            endXText = corner + (endX-corner) * tv.textVectorNormalizedPosition;
            endYText = corner + (endY-corner) * tv.textVectorNormalizedPosition;
            endZText = corner + (endZ-corner) * tv.textVectorNormalizedPosition;
            
            % assemble all the points again
            allPointsFig = [corner endX endY endZ endXText endYText endZText];          

            % convert back to figure units
            allPointsFig(1, :) = allPointsFig(1, :) * xUnitsToNorm;
            allPointsFig(2, :) = allPointsFig(2, :) * yUnitsToNorm;
            allPointsFig(3, :) = allPointsFig(3, :) * zUnitsToNorm;

            % translate the axis indicators to avoid leaving the outer
            % position box + the axis inset
            set(tv.ht, 'Units', 'data');
            textExtents = get(tv.ht, 'Extent');
            textExtents = cat(1, textExtents{:});
            maxTextWidth = max(textExtents(:, 3));
            maxTextHeight = max(textExtents(:, 4));
            xMin = min(allPointsFig(1, :));
            yMin = min(allPointsFig(2, :));
            
            allPointsFig(1, :) = allPointsFig(1, :) -xMin + pos(1)+offsetX+maxTextWidth/2;
            allPointsFig(2, :) = allPointsFig(2, :) -yMin + pos(2)+offsetY+maxTextHeight/2;
            if ~tv.positionFrozen || isempty(tv.positionFrozenCorner)
                tv.positionFrozenCorner = allPointsFig(1:2, 1);
            else 
                allPointsFig(1, :) = allPointsFig(1, :) - allPointsFig(1, 1) + tv.positionFrozenCorner(1);
                allPointsFig(2, :) = allPointsFig(2, :) - allPointsFig(2, 1) + tv.positionFrozenCorner(2);
            end
            
            % no need to convert back to data coordinates since we're
            % plotting in the overlay axis whose data coords match the
            % figure coordinates
            allPoints = allPointsFig; 
            % z coordinate doesn't matter, we want the projection into 
            % the overlay axis
            allPoints(3, :) = 0; 

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
                'BackgroundColor', 'none', 'Interpreter', tv.interpreter, 'Margin', tv.textMargin);
            
            for iA = 1:3
                tv.ht(iA).HorizontalAlignment = tv.labelHorizontalAlignment(iA);
                tv.ht(iA).VerticalAlignment = tv.labelVerticalAlignment(iA);
            end
            
            % update background rectangle
            lox = min(allPointsFig(1, :));
            hix = max(allPointsFig(1, :));
            dx = tv.backgroundMargin * xUnitsToNorm;
            loy = min(allPointsFig(2, :));
            hiy = max(allPointsFig(2, :));
            dy = tv.backgroundMargin * yUnitsToNorm;
            back_x = [lox - dx; hix + dx; hix + dx; lox - dx];
            back_y = [loy - dy; loy - dy; hiy + dy; hiy + dy];
            set(tv.hback, 'XData', back_x, 'YData', back_y, ...
                'FaceColor', tv.backgroundColor, 'FaceAlpha', tv.backgroundAlpha);
            if tv.background
                set(tv.hback, 'Visible', 'on');
            else
                set(tv.hback, 'Visible', 'off');
            end
            
            set(tv.ht, 'Visible', 'on');
            set(tv.hv, 'Visible', 'on');
            
            % hide specific axes for special projections
            v = get(axh, 'View');
            az = v(1);
            el = v(2);
            if el == 0 && mod(az, 180) == 90
                % hide x
                set(tv.hv(1), 'Visible', 'off');
                set(tv.ht(1), 'Visible', 'off');
            elseif el == 0 && mod(az, 180) == 0
                % hide y
                set(tv.hv(2), 'Visible', 'off');
                set(tv.ht(2), 'Visible', 'off');
            elseif mod(el, 180) == 90
                % hide z
                set(tv.hv(3), 'Visible', 'off');
                set(tv.ht(3), 'Visible', 'off')
            end
  
            figh = ThreeVector.getParentFigure(axh);
            
            if tv.niceGrid
                axis(axh, 'on');
                if tv.hideAxes
                    axh.XLabel.Visible = 'off';
                    axh.YLabel.Visible = 'off';
                    axh.ZLabel.Visible = 'off';
                    
                    axh.XRuler.Visible = 'off';
                    axh.YRuler.Visible = 'off';
                    axh.ZRuler.Visible = 'off';
                else
                    axh.XLabel.Visible = 'on';
                    axh.YLabel.Visible = 'on';
                    axh.ZLabel.Visible = 'on';
                    
                    axh.XRuler.Visible = 'on';
                    axh.YRuler.Visible = 'on';
                    axh.ZRuler.Visible = 'on';
                end
                axh.Color = [0.92 0.92 0.95];
                axh.GridColor = [1 1 1];
                axh.GridAlpha = 1;
                axh.GridLineStyle = '-';
                axh.MinorGridColor =  [0.96 0.96 0.96];
                axh.MinorGridAlpha = 1;
                axh.MinorGridLineStyle = '-';

                grid(axh, 'on');
                figh.InvertHardcopy = 'off';
            else
                axh.Color = 'none';
                if tv.hideAxes
                    axis(axh, 'off');
                    axh.XLabel.Visible = 'off';
                    axh.YLabel.Visible = 'off';
                    axh.ZLabel.Visible = 'off';
                else
                    axis(axh, 'on');
                    axh.XLabel.Visible = 'on';
                    axh.YLabel.Visible = 'on';
                    axh.ZLabel.Visible = 'on';
                end
            end

            figh.CurrentAxes = axh;
        end
        
        function freezePosition(tv)
            tv.positionFrozen = true;
        end
        
        function unfreezePosition(tv)
            tv.positionFrozen = false;
        end
    end
    
    methods % Auto-update proprerty setters
        function set.fontSize(tv, v)
            tv.fontSize = v;
            tv.update();
        end
        
        function set.fontColor(tv, v) 
            tv.fontColor = ThreeVector.convertColor(v);
            tv.update();
        end
        
        function set.lineWidth(tv, v)
            tv.lineWidth = v;
            tv.update();
        end

        function set.lineColor(tv, v)
            tv.lineColor = ThreeVector.convertColor(v);
            tv.update();
        end
        
        function set.vectorLength(tv, v) 
            tv.vectorLength = v;
            tv.update();
        end
        
        function set.textVectorNormalizedPosition(tv, v) 
            tv.textVectorNormalizedPosition = v;
            tv.update();
        end
        
        function set.axisInset(tv, v) 
            tv.axisInset = v;
            tv.update();
        end
    end
    
    methods(Static) % Public static utility methods
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
        
        function updateAxis(axh)
            % call update on axis if installed
            if nargin < 1, axh = gca; end
            tvTest = ThreeVector.recoverForAxis(axh);
            if isempty(tvTest)
                warning('ThreeVector not installed on axis');
            else
                tvTest.update();
            end
        end
        
        function tv = demo()
            % load a demo figure and install ThreeVector
            figure(); clf; set(gcf, 'Color', 'w');
            P = peaks(40);
            C = del2(P);
            h = surf(P,C);
            set(h, 'EdgeColor', 'none');
            shading interp
            colormap hot
            view([322 39]);

            hold on; 
            axis off; 
            axis tight;
            set(gca, 'LooseInset', [ 0 0 0 0 ]);
            xlabel('X');
            ylabel('Y');
            zlabel('Z');
            %axis vis3d;
            
            tv = ThreeVector(gca);
            rotate3d on;
        end
    end
    
    methods(Static, Access=protected) % static utility methods
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
            if ThreeVector.isMultipleCall(), return, end
            ThreeVector.updateFigure(figh);
        end
             
        function preUpdateCallback(varargin)
            % callback called before update
            if ThreeVector.isMultipleCall(), return, end
            if isfield(varargin{2}, 'Axes')
                axh = varargin{2}.Axes;
                tv = ThreeVector.recoverForAxis(axh);
                set(tv.ht, 'Visible', 'off');
                set(tv.hv, 'Visible', 'off');
            end
        end
        
        function axisCallback(varargin)
            % callback called on specific axis
            if ThreeVector.isMultipleCall(), return, end
            if isfield(varargin{2}, 'Axes')
                axh = varargin{2}.Axes;
                tv = ThreeVector.recoverForAxis(axh);
                tv.updateAxh(axh);
                tv.update();
            end
        end
        
        function fig = getParentFigure(axh)
            % if the object is a figure or figure descendent, return the
            % figure. Otherwise return [].
            fig = ancestor(axh, 'figure');
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
        
        function cvec = convertColor(c)
            if ~ischar(c)
                cvec = c;
            else
                switch c
                    case 'b'
                        cvec = [0 0 1];
                    case 'g'
                        cvec = [0 1 0];
                    case 'r'
                        cvec = [1 0 0];
                    case 'c'
                        cvec = [0 1 1];
                    case 'm'
                        cvec = [1 0 1];
                    case 'y'
                        cvec = [1 1 0];
                    case 'k'
                        cvec = [0 0 0];
                    case 'w'
                        cvec = [1 1 1];
                    otherwise
                        error('Unknown color string');
                end
            end
        end
    end
    
    methods
        function reinstallPostLoad(tv)
            % recover handles via tags, and reinstall callbacks
            
            % first find overlay axes
            figh = ThreeVector.getParentFigure(tv.axh);
            h = findobj(figh, 'Type', 'axes', 'Tag', tv.axhOverlayTag);
            if isempty(h)
                warning('Could not recover tagged handle %s', tag);
            end
            tv.axhOverlay = h;
            
            % then find objects within overlay axes
            h = tv.recoverTaggedHandles();
            tv.hv = h.hv;
            tv.ht = h.ht;
            
            tv.installInstanceForAxis(tv.axh);
            tv.installCallbacks();
        end
    end
    
    methods(Access=protected) % installation, handle tagging and recovery
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
            tv.fontSize = get(tv.axh, 'FontSize');
            tv.lineWidth = 2;
            tv.fontColor = [0.1 0.1 0.1];
            tv.lineColor = [0.4 0.4 0.4];
            
            tv.initialize();
            tv.update();
            tv.installCallbacks();
        end
        
        function initialize(tv)
            figh = ThreeVector.getParentFigure(tv.axh);
            
            % create an overlay axis with unique tag, store the tag
            % set to match outer postition with x/y lims [0 1]
            pos = get(tv.axh, 'OuterPosition');
            tv.axhOverlayTag = tv.generateTagForAxis();
            tv.axhOverlay = axes('Position', pos, 'Color', 'none', ...
                'XLim', [pos(1) pos(1)+pos(3)], 'YLim', [pos(2) pos(2)+pos(4)], ...
                'Tag', tv.axhOverlayTag, 'HitTest', 'off', ...
                'Parent', figh);

            uistack(tv.axhOverlay, 'top');
            hold(tv.axhOverlay, 'on');
            
            % draw the background
            tv.hback = patch([0;1;1;0], [0;0;1;1], tv.backgroundColor, ...
                'Parent', tv.axhOverlay, 'EdgeColor', 'none');
            
            % draw the axis vectors and the text labels
            if ~isempty(tv.hv)
                delete(tv.hv);
            end
            if verLessThan('matlab','8.4.0')
                lineSmoothingArgs = {'LineSmoothing', 'on'};
            else
                lineSmoothingArgs = {};
            end
            tv.hv = gobjects(3, 1);
            tv.hv(1) = plot([0 1], [0 1], '-', lineSmoothingArgs{:}, 'Parent', tv.axhOverlay);
            tv.hv(2) = plot([0 1], [0 1], '-', lineSmoothingArgs{:}, 'Parent', tv.axhOverlay);
            tv.hv(3) = plot([0 1], [0 1], '-', lineSmoothingArgs{:}, 'Parent', tv.axhOverlay);

            if ~isempty(tv.ht)
                delete(tv.ht);
            end
            
            tv.ht = gobjects(3, 1);
            tv.ht(1) = text(0, 1, 'X', 'HorizontalAlign', 'Left', 'Parent', tv.axhOverlay, 'Units', 'Normalized', 'Margin', tv.textMargin);
            tv.ht(2) = text(0, 2, 'Y', 'HorizontalAlign', 'Left', 'Parent', tv.axhOverlay, 'Units', 'Normalized', 'Margin', tv.textMargin);
            tv.ht(3) = text(0, 3, 'Z', 'HorizontalAlign', 'Left', 'Parent', tv.axhOverlay, 'Units', 'Normalized', 'Margin', tv.textMargin);
            
            axis(tv.axhOverlay, 'off');
            
            %ThreeVector.hideInLegend(tv.hv);
            %ThreeVector.hideInLegend(tv.ht);
            
            % tag handles so that they can be recovered on save/load
            handleStruct = struct();
            handleStruct.hv = tv.hv;
            handleStruct.ht = tv.ht;
            handleStruct.hback = tv.hback;
            tv.tagHandlesForRecovery(handleStruct);
        end
        
        function tag = generateTagForAxis(tv) %#ok<MANU>
            % generate a random string tag to use for the transparent
            % overlay axis
            
            %s = RandStream('mt19937ar', 'Seed', tv.axh);
            s = RandStream('mt19937ar');
            letters = 'a':'z';
            tag = ['axis_' letters(randi(s, 26, 10, 1))];
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
            if ~tv.useCallbacks, return, end
            % install update callbacks for zoom, pan, rotate, resize, x/y/z
            % label changes, x/y/z lims changes
            figh = ThreeVector.getParentFigure(tv.axh);
            
            set(zoom(tv.axh),'ActionPreCallback',@ThreeVector.preUpdateCallback);
            set(zoom(tv.axh),'ActionPostCallback',@ThreeVector.axisCallback);
            
            set(pan(figh),'ActionPreCallback',@ThreeVector.preUpdateCallback);
            set(pan(figh),'ActionPostCallback',@ThreeVector.axisCallback);
            set(figh, 'ResizeFcn', @ThreeVector.figureCallback);
            
            rot = rotate3d(tv.axh);
            set(rot, 'ActionPreCallback', @ThreeVector.preUpdateCallback);
            set(rot, 'ActionPostCallback', @ThreeVector.axisCallback);
            rot.Enable = 'on';
            
            %set(rotate3d(tv.axh),'ActionPreCallback',@ThreeVector.preUpdateCallback);
            %set(rotate3d(tv.axh), 'ActionPostCallback', @ThreeVector.axisCallback);
            
            addlistener(tv.axh, {'XLim', 'YLim', 'ZLim'}, 'PostSet', @tv.localCallback);
            addlistener(get(tv.axh, 'XLabel'), 'String', 'PostSet', @tv.localCallback);
            addlistener(get(tv.axh, 'YLabel'), 'String', 'PostSet', @tv.localCallback);
            addlistener(get(tv.axh, 'ZLabel'), 'String', 'PostSet', @tv.localCallback);
            
            addlistener(tv.axh, 'CameraPosition', 'PostSet', @tv.localViewChangeCallback);
            addlistener(tv.axh, 'CameraTarget', 'PostSet', @tv.localViewChangeCallback);
            addlistener(tv.axh, 'CameraUpVector', 'PostSet', @tv.localViewChangeCallback);
            addlistener(tv.axh, 'Position', 'PostSet', @tv.localCallback);
             addlistener(tv.axh, 'View', 'PostSet', @tv.localCallback);
        end
        
        function localCallback(tv, varargin)
            % perform an update. This method must be called with the
            % correct ThreeVector instance, whereas
            % ThreeVector.axisCallback will automatically find the right
            % ThreeVector instance for the active axis.
            
            if ThreeVector.isMultipleCall(), return, end
            tv.update();
        end
        
        function localViewChangeCallback(tv, varargin)
            % perform an update. This method must be called with the
            % correct ThreeVector instance, whereas
            % ThreeVector.axisCallback will automatically find the right
            % ThreeVector instance for the active axis.
            
            if ThreeVector.isMultipleCall(), return, end
            hasChanged = tv.updateTransforms();
            if hasChanged
                tv.update();
            end
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
                h.(f) = gobjects(numel(tv.handleTags.(f)), 1);
                for j = 1:numel(tv.handleTags.(f))
                    tag = tv.handleTags.(f){j};
                    % important that we search inside axhOverlay
                    val = findobj(tv.axhOverlay, 'Tag', tag);
                    if isempty(val)
                        warning('Could not recover tagged handle %s', tag);
                    end
                    h.(f)(j) = val;
                end
            end
        end
    end
    
    methods(Static) % Loading from disk
        function tv = loadobj(tv)
            % defer reconfiguring until we have our figure set as parent
            if isstruct(tv)
                return;
            end
            try
                tv.hListenerTemp = addlistener(tv.axh, {'Parent'}, 'PostSet', @(varargin) tv.reinstallPostLoad());
            catch
            end
        end
    end
    
    methods(Access=protected) % methods for computing positions of annotations
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
        
        function hasChanged = updateTransforms(tv)
            % compute data <-> normalized coordinate transforms
            old = tv.dataToFig;
            tv.dataToFig = tv.getDataToFigureCoordinateTransform();
            
            hasChanged = ~isequal(old, tv.dataToFig);
        end
        
        function [posNorm, posPixels, posCm] = getTrueAxesPosition(tv, outer, args)
            % based on plotboxpos by Kelly Kearney https://github.com/kakearney/plotboxpos-pkg
            %PLOTBOXPOS Returns the position of the plotted axis region
            %
            % pos = plotboxpos(h)
            %
            % This function returns the position of the plotted region of an axis,
            % which may differ from the actual axis position, depending on the axis
            % limits, data aspect ratio, and plot box aspect ratio.  The position is
            % returned in the same units as the those used to define the axis itself.
            % This function can only be used for a 2D plot.  
            %
            % Input variables:
            %
            %   h:      axis handle of a 2D axis (if ommitted, current axis is used).
            %
            % Output variables:
            %
            %   pos:    four-element position vector, in same units as h
            % Copyright 2010 Kelly Kearney
            % Check input

            arguments
                tv
                outer = false
                args.normRelativeToFigure = true;
            end

            h = tv.axh;
            
            % Get position of axis in pixels
            currunits = h.Units;
            h.Units = 'Pixels';
            if outer
                axisPos = h.OuterPosition;
            else
                axisPos = h.Position;
            end
            
            % Calculate box position based axis limits and aspect ratios
            darismanual  = strcmpi(get(h, 'DataAspectRatioMode'),    'manual');
            pbarismanual = strcmpi(get(h, 'PlotBoxAspectRatioMode'), 'manual');
            if ~darismanual && ~pbarismanual
                % simple case
                posPixels = axisPos;
                h.Units = 'normalized';
                posNorm = h.Position;
                h.Units = 'centimeters';
                posCm = h.Position;
                h.Units = currunits;
                return;
                
            else
                xlim = get(h, 'XLim');
                ylim = get(h, 'YLim');

                % Deal with axis limits auto-set via Inf/-Inf use

                if any(isinf([xlim ylim]))
                    hc = get(h, 'Children');
                    hc(~arrayfun( @(h) isprop(h, 'XData' ) & isprop(h, 'YData' ), hc)) = [];
                    xdata = get(hc, 'XData');
                    if iscell(xdata)
                        xdata = cellfun(@(x) x(:), xdata, 'uni', 0);
                        xdata = cat(1, xdata{:});
                    end
                    ydata = get(hc, 'YData');
                    if iscell(ydata)
                        ydata = cellfun(@(x) x(:), ydata, 'uni', 0);
                        ydata = cat(1, ydata{:});
                    end
                    isplotted = ~isinf(xdata) & ~isnan(xdata) & ...
                                ~isinf(ydata) & ~isnan(ydata);
                    xdata = xdata(isplotted);
                    ydata = ydata(isplotted);
                    if isempty(xdata)
                        xdata = [0 1];
                    end
                    if isempty(ydata)
                        ydata = [0 1];
                    end
                    if isinf(xlim(1))
                        xlim(1) = min(xdata);
                    end
                    if isinf(xlim(2))
                        xlim(2) = max(xdata);
                    end
                    if isinf(ylim(1))
                        ylim(1) = min(ydata);
                    end
                    if isinf(ylim(2))
                        ylim(2) = max(ydata);
                    end
                end
                dx = diff(xlim);
                dy = diff(ylim);
                dar = get(h, 'DataAspectRatio');
                pbar = get(h, 'PlotBoxAspectRatio');
                limDarRatio = (dx/dar(1))/(dy/dar(2));
                pbarRatio = pbar(1)/pbar(2);
                axisRatio = axisPos(3)/axisPos(4);
                if darismanual
                    if limDarRatio > axisRatio
                        pos(1) = axisPos(1);
                        pos(3) = axisPos(3);
                        pos(4) = axisPos(3)/limDarRatio;
                        pos(2) = (axisPos(4) - pos(4))/2 + axisPos(2);
                    else
                        pos(2) = axisPos(2);
                        pos(4) = axisPos(4);
                        pos(3) = axisPos(4) * limDarRatio;
                        pos(1) = (axisPos(3) - pos(3))/2 + axisPos(1);
                    end
                elseif pbarismanual
                    if pbarRatio > axisRatio
                        pos(1) = axisPos(1);
                        pos(3) = axisPos(3);
                        pos(4) = axisPos(3)/pbarRatio;
                        pos(2) = (axisPos(4) - pos(4))/2 + axisPos(2);
                    else
                        pos(2) = axisPos(2);
                        pos(4) = axisPos(4);
                        pos(3) = axisPos(4) * pbarRatio;
                        pos(1) = (axisPos(3) - pos(3))/2 + axisPos(1);
                    end
                end
            end
            % Convert plot box position to the units used by the axis
            hparent = get(h, 'parent');
            hfig = ancestor(hparent, 'figure'); % in case in panel or similar
            currax = get(hfig, 'currentaxes');

            temp = axes('Units', 'Pixels', 'Position', pos, 'Visible', 'off', 'parent', hfig);
            posPixels = temp.Position;
            temp.Units = 'Normalized';
            posNorm = temp.Position;
            temp.Units = 'centimeters';

            if isa(hparent, 'matlab.graphics.layout.TiledChartLayout') && args.normRelativeToFigure
                % posNorm is in units normalized to the tiled chart layout's position, not the figure, which is what we
                % want
                tiled_pos = hparent.Position;
                posNorm = [tiled_pos(1) + posNorm(1), tiled_pos(2) + posNorm(2), tiled_pos(3) * posNorm(3), tiled_pos(4) * posNorm(4)];
            end

            posCm = temp.Position;
            delete(temp);
            h.Units = currunits;
            set(hfig, 'currentaxes', currax);
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
            
%             old = false;
%             if old
%                 % axes position
%                 axesUnitsOriginal = get(hAxes, 'Units');
%                 set(hAxes, 'Units', 'normalized'); 
%                 positionNormal = get(hAxes, 'Position');
%                 set(hAxes, 'Units', 'pixels'); 
%                 positionPixel = get(hAxes, 'Position');
%                 set(hAxes, 'Units', axesUnitsOriginal);
%             else
                [positionNormal, positionPixel] = tv.getTrueAxesPosition();
%             end
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
            
%              matrixTransform = matrixViewPort * matrixProjection * ...
%                 matrixRotate * matrixRescale * matrixTranslate;
        end
        
    end
end




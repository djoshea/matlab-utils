classdef BarPlot < handle
% function to plot bar plots with error bars

    properties % appearance properties
        baseline = 0;
        baselineColor = [0.6 0.6 0.6];
        baselineLineWidth = 1;
        
        barWidth = 0.8;
        
        barFaceColor = [ 0.4 0.4 0.4 ];
        barEdgeColor = 'none';
        
        errorLineColor = [0.2 0.2 0.2];
        errorLineWidth = 0.2;
        
        barFontWeight = 'normal';
        barFontSize
        barFontColor
        barLabelHorizontalAlignment = 'left';
        barLabelRotation = -45;
        
        groupFontWeight = 'bold';
        groupFontSize
        groupFontColor
        
        groupLineOverhang = 0.15;
        
        barGap = 0.2;
        groupGap = 1;
    end
    
    properties(SetAccess=protected) % state variables
        xc = 0;
        axh
        autoAxis
        inGroup = false;
        currentGroupName = '';
        xGroupStart = NaN;
    end
        
    methods
        function b = BarPlot(axh)
            if nargin < 1
                b.axh = gca;
            else
                b.axh = axh;
            end
            
            b.autoAxis = AutoAxis(b.axh);
            
            % set defaults
            sz = get(b.axh, 'FontSize');
            tc = get(b.axh, 'DefaultTextColor');
            
            b.barFontSize = sz;
            b.groupFontSize = sz;
            b.barFontColor = tc;
            b.groupFontColor = tc;
            
            b.autoAxis.addAutoAxisY();
            b.autoAxis.installCallbacks();
            b.autoAxis.update();
        end
    end
    
    methods
        function startGroup(b, name, varargin)
            if nargin < 2
                name = '';
            end
            b.xc = b.xc + b.groupGap / 2;
            
            b.currentGroupName = name;
            b.xGroupStart = b.xc;
            b.inGroup = true;
        end
        
        function [hBar, hLine, hLabel] = addBar(b, value, varargin)
            p = inputParser();
            p.addParamValue('label', '', @ischar);
            
            p.addParamValue('confLow', [], @(x) isempty(x) || isscalar(x));
            p.addParamValue('confHigh', [], @(x) isempty(x) || isscalar(x));
            p.addParamValue('errorLow', [], @(x) isempty(x) || isscalar(x));
            p.addParamValue('errorHigh', [], @(x) isempty(x) || isscalar(x));
            p.addParamValue('error', [], @(x) isempty(x) || isscalar(x));
            
            p.addParamValue('faceColor', b.barFaceColor, @(x) true);
            p.addParamValue('edgeColor', b.barEdgeColor, @(x) true);
            
            p.parse(varargin{:});
            
            if ~isempty(p.Results.error)
                confLow = value - p.Results.error;
                confHigh = value + p.Results.error;
            else
                if ~isempty(p.Results.errorHigh)
                    confHigh = value + p.Results.errorHigh;
                else
                    confHigh = p.Results.confHigh;
                end
                if ~isempty(p.Results.errorLow)
                    confLow = value - p.Results.errorLow;
                else
                    confLow = p.Results.confLow;
                end
            end
            if isempty(confHigh)
                confHigh = value;
            end
            if isempty(confLow)
                confLow = value;
            end
            
            p.parse(varargin{:});
            
            b.xc = b.xc + b.barGap / 2;
            
            if(value ~= 0)
                hBar = rectangle('Position', [b.xc, min(0, value), b.barWidth, abs(value)], ...
                    'Parent', b.axh, ...
                    'FaceColor', p.Results.faceColor, 'EdgeColor',p.Results.edgeColor);
            else
                hBar = NaN;
            end
            
            if confHigh ~= confLow
                hLine = rectangle('Position', ...
                    [b.xc+b.barWidth/2-b.errorLineWidth/2, confLow, b.errorLineWidth, confHigh-confLow], ...
                    'Parent', b.axh, ...
                    'FaceColor', b.errorLineColor, 'EdgeColor', 'none');
                hasbehavior(hLine, 'legend', false);
            else
                hLine = NaN;
            end
            
            % add label underneath axis
            yl = get(b.axh, 'YLim');
            hLabel = text(b.xc + b.barWidth/2, yl(1), p.Results.label, ...
                'Color', b.barFontColor, 'FontWeight', b.barFontWeight, ...
                'FontSize', b.barFontSize, 'Parent', b.axh, ...
                'VerticalAlignment', 'top', 'HorizontalAlignment', b.barLabelHorizontalAlignment, ...
                'Rotation', b.barLabelRotation);
            
            b.autoAxis.addHandlesToCollection('BarPlot_barLabels', hLabel);
            
            b.xc = b.xc + b.barWidth + b.barGap/2;
            
            b.autoAxis.update();
        end
        
        function hLine = endGroup(b, varargin)
            
            xGroupEnd = b.xc;
            
            % draw group line
            hLine = line([b.xGroupStart xGroupEnd], [b.baseline b.baseline], ...
                'LineWidth', b.baselineLineWidth, 'Parent', b.axh, ...
                'Color', b.baselineColor);
            
            if ~isempty(b.currentGroupName)
                hText = text(mean([b.xGroupStart xGroupEnd]), b.baseline, ...
                    b.currentGroupName, 'Parent', b.axh, ...
                    'Color', b.groupFontColor, 'FontWeight', b.groupFontWeight, ...
                    'FontSize', b.groupFontSize, ...
                    'VerticalAlignment', 'top', 'HorizontalAlignment', 'center');
   
                import AutoAxis.PositionType;
                a = AutoAxis.AnchorInfo(hText, PositionType.Top, 'BarPlot_barLabels', ...
                    PositionType.Bottom, 'tickLabelOffset', ...
                    sprintf('BarPlot: anchor group %s label to bottom of line', b.currentGroupName));
                b.autoAxis.addAnchor(a);
                
                a = AutoAxis.AnchorInfo(hText, PositionType.HCenter, hLine, ...
                    PositionType.HCenter, 0, ...
                    sprintf('BarPlot: anchor group %s label centered on line', b.currentGroupName));
                b.autoAxis.addAnchor(a);
            else
                hText = NaN;
            end

            b.xc = b.xc + b.groupGap / 2;
            b.currentGroupName = '';
            b.xGroupStart = NaN;
            b.inGroup = false;
            
            b.autoAxis.update();
        end
    end
    
end


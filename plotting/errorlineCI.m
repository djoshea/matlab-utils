function [h, hError] = errorlineCI(x,y, ci, varargin)
% like errorbar, except plots vertical lines that look nice 

    p = inputParser();
    p.addParamValue('Parent', gca, @isscalar);
    p.addParamValue('Color', 'k', @(x) true);
    p.addParamValue('LineStyle', '-', @ischar);
    p.addParamValue('LineAlpha', 1, @isscalar);
    p.addParamValue('LineWidth', 1, @isscalar);
    p.addParamValue('Marker', 'o', @ischar);
    p.addParamValue('MarkerSize', 6, @isscalar);
    p.addParamValue('MarkerAlpha', 1, @isscalar);
    p.addParamValue('MarkerFaceColor', [], @(x) true);
    p.addParamValue('MarkerEdgeColor', [], @(x) true);
    
    p.addParamValue('ErrorLineWidth', 1, @isscalar);
    p.addParamValue('ErrorColor', [], @(x) true);
    p.addParamValue('ErrorLineAlpha', 1, @isscalar);
    p.CaseSensitive = false;
    p.parse(varargin{:});
    
    x = makecol(x);
    y = makecol(y);
    axh = p.Results.Parent;
    
    if isempty(p.Results.ErrorColor)
        errorColor = p.Results.Color;
    else
        errorColor = p.Results.ErrorColor;
    end
    
    if isempty(p.Results.MarkerFaceColor)
        markerFaceColor = p.Results.Color;
    else
        markerFaceColor = p.Results.MarkerFaceColor;
    end
    
    if isempty(p.Results.MarkerEdgeColor)
        markerEdgeColor = markerFaceColor;
    else
        markerEdgeColor = p.Results.MarkerEdgeColor;
    end
    
    h = plot(x,y, 'Parent', axh, 'LineStyle', p.Results.LineStyle, ...
        'Color', p.Results.Color, 'MarkerEdgeColor', markerEdgeColor, ...
        'MarkerFaceColor', markerFaceColor, 'LineWidth', p.Results.LineWidth, ...
        'Marker', p.Results.Marker, 'MarkerSize', p.Results.MarkerSize);
    
    if p.Results.LineAlpha < 1
        SaveFigure.setLineOpacity(h, p.Results.LineAlpha);
    end
    
    if p.Results.MarkerAlpha < 1
        SaveFigure.setMarkerOpacity(h, p.Results.MarkerAlpha);
    end
    
    origHold = ishold(axh);
    hold(axh, 'on');

    hError = line([x'; x'], ci', 'Parent', axh, ...
        'Color', errorColor, 'LineWidth', p.Results.ErrorLineWidth);

    if p.Results.ErrorLineAlpha < 1
        SaveFigure.setLineOpacity(hError, p.Results.ErrorLineAlpha);
    end
    
    if ~origHold
        hold(axh, 'off');
    end
end

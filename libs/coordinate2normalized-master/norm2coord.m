function [xcoord, ycoord] = norm2coord(axishandle, x, y)
%NORM2COORD Map container normalized coordinates to axes data space
% NORM2COORD(axishandle, x, y) takes input XY coordinates normalized to the
% parent container of the axes object, axishandle, and maps them to
% cartesian coordinates in the data space of the axes object. This is 
% useful when interacting with functions like annotation, where the input
% XY coordinates are normalized to the parent container of the plotting
% axes object and not to the data being plotted. axishandle must be a valid
% MATLAB axes object (HG2) or handle (HG1).
%
% COORD2NORM returns discrete arrays xcoord and ycoord of the same size as
% the input XY normalized coordinate arrays.
%
% Example:
%
%    myaxes = axes();
%    x = -10:10;
%    y = x.^2;
%    plot(x, y);
%
%    normx = [0.5, 0.55];
%    normy = [0.5, 0.55];
%    annotation('arrow', normx, normy);
%
%    hold on;
%    [coordx, coordy] = norm2coord(myaxes, normx, normy);
%    plot(coordx, coordy, 'or')
%
% See also ANNOTATION, PLOT, AXES, FIGURE

checkinputs(axishandle, x, y);

% Check to see if one or both axes is logarithmic to set flag appropriately
olderthanR2014b = verLessThan('MATLAB', '8.4');  % Version flag to be used for calling correct syntax
if ~olderthanR2014b % Choose correct syntax for accessing handle graphics
    xaxisscale = axishandle.XScale;
    yaxisscale = axishandle.YScale;
else
    xaxisscale = get(axishandle, 'XScale');
    yaxisscale = get(axishandle, 'YScale');
end

if strcmp(xaxisscale, 'linear') && strcmp(yaxisscale, 'linear')
    flag = 'linear';
elseif strcmp(xaxisscale, 'log') && strcmp(yaxisscale, 'log')
    flag = 'loglog';
elseif strcmp(xaxisscale, 'log') && strcmp(yaxisscale, 'linear')
    flag = 'semilogx';
elseif strcmp(xaxisscale, 'linear') && strcmp(yaxisscale, 'log')
    flag = 'semilogy';
end

[xcoord, ycoord] = coordmap(axishandle, x, y, flag);
end

function checkinputs(axishandle, x, y)
olderthanR2014b = verLessThan('MATLAB', '8.4');  % Version flag to be used for calling correct syntax

% Make sure the object passed is an axes object
% Return true if it's a valid axes, false otherwise
if ~olderthanR2014b
    isaxes = isa(axishandle, 'matlab.graphics.axis.Axes');
    objtype = class(axishandle);
else
    try
        objtype = get(axishandle, 'Type');
        if strcmp(objtype, 'axes')
            isaxes = true;
        else
            isaxes = false;
        end
    catch
        objtype = 'N/A';
        isaxes = false;
    end
end
if ~isaxes
    err.message = sprintf('First input to function must be a MATLAB Axes object, not %s', objtype);
    err.identifier = 'norm2coord:InvalidObject';
    err.stack = dbstack('-completenames');
    error(err)
end

% Make sure there is something plotted on the axes, otherwise we can get
% negative normalized values, which do not make sense
% Return true if children are present, false otherwise
if ~olderthanR2014b % Choose correct syntax for accessing handle graphics
    childrenpresent = ~isempty(axishandle.Children);
else
    childrenpresent = ~isempty(get(axishandle, 'Children'));
end
if ~childrenpresent
    err.message = 'Data has not been plotted on input Axes object';
    err.identifier = 'norm2coord:NoDataPlotted';
    err.stack = dbstack('-completenames');
    error(err)
end

% Make sure XY arrays are not empty
if isempty(x) || isempty(y)
    err.message = 'XY arrays must not be empty';
    err.identifier = 'norm2coord:EmptyXYarray';
    err.stack = dbstack('-completenames');
    error(err)
end

% Make sure input XY data is normalized (between 0 and 1)
if max(x) > 1 || min(x) < 0 || max(y) > 1 || min(y) < 0
    if max(x) > 1 || min(x) < 0
        err.message = sprintf('Normalized X values must be between 0 and 1.\nX Range: [%.2f, %.2f]', min(x), max(x));
    elseif max(y) > 1 || max(y) < 0
        err.message = sprintf('Normalized Y values must be between 0 and 1.\nY Range: [%.2f, %.2f]', min(y), max(y));
    end
    err.identifier = 'norm2coord:DataNotNormalized';
    err.stack = dbstack('-completenames');
    error(err)
end

end

function [xcoord, ycoord] = coordmap(axishandle, x, y, flag)
% The Position property of MATLAB's axes object is its position relative to
% the parent object. MATLAB's annotation objects are positioned relative to
% a figure, uipanel, or uitab object so we have to use the size and
% position of the axes object to map the normalized coordinates back to the
% axes. Note that errors introduced during the conversion process may be
% significant, particularly in the case of logarithmic scales, so
% attempting to test for equivalence may yield unexpected results.
%
% Uses flag to determine if one or both of the axes is logarithmic

% Get axes position
olderthanR2014b = verLessThan('MATLAB', '8.4');  % Version flag to be used for calling correct syntax
if ~olderthanR2014b  % Choose correct syntax for accessing handle graphics
    oldunits = axishandle.Units;         % Get old units to revert to later
    axishandle.Units = 'Normalized';     % Set normalized units if not already
    axisposition = axishandle.Position;  % Get position in figure window
    axishandle.Units = oldunits;         % Revert unit change
else
    oldunits = get(axishandle, 'Units');
    set(axishandle, 'Units', 'Normalized');
    axisposition = get(axishandle, 'Position');
    set(axishandle, 'Units', oldunits);
end

axislimits = axis(axishandle);

% If an axis uses the log scale, replace that axis' limits with
% log10(limits) for the following axiswidth/axisheight calculations to make
% sense in the context of the MATLAB figure.
switch flag
    case 'linear'
        % No modification necessary
    case 'loglog'
        axislimits = log10(axislimits);
    case 'semilogx'
        axislimits(1:2) = log10(axislimits(1:2));
    case 'semilogy'
        axislimits(3:4) = log10(axislimits(3:4));
end

axisdatawidth  = axislimits(2) - axislimits(1);
axisdataheight = axislimits(4) - axislimits(3);

% Normalize x values
xcoord = (x - axisposition(1))*(axisdatawidth/axisposition(3)) + axislimits(1);
% Normalize y values
ycoord = (y - axisposition(2))*(axisdataheight/axisposition(4)) + axislimits(3);

% One final transformation required for log plots.
switch flag
    case 'linear'
        % No modification necessary
    case 'loglog'
        xcoord = 10.^xcoord;
        ycoord = 10.^ycoord;
    case 'semilogx'
        xcoord = 10.^xcoord;
    case 'semilogy'
        ycoord = 10.^ycoord;
end

end


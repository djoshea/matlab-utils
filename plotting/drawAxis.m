
% plots an axis / calibration
%
% usage: outParams = AxisMMC(start, fin, varargin)
% 
% 'start' and 'fin' are the starting and ending values of the axis
% 'params' is an optional structure with one or more of the following fields
%         tickLocations    default =  [start fin]
%            tickLabels    default = {'start',  'fin'}
%    tickLabelLocations    default is the numerical values of the labels themselves
%             longTicks    default is ticks with labels are long
%           extraLength    default = 0.5500  long ticks are this proportion longer
%             axisLabel    default = '' (no label)
%            axisOffset    default = 0
%       axisOrientation    default = 'h' ('h' = horizontal, 'v' = vertical)
%          axisPosition    default = 0 (position on opposite axis to locate the axis line, before the offset)
%                invert    default = 0
%            tickLength    default is 1/100 of total figure span
%       tickLabelOffset    default based on tickLength
%       axisLabelOffset    default based on tickLength
%         lineThickness    default = 1
%                 color    default = 'k'
%           labelColors    default = 'k', Nx3 array of colors by label or single color row / char
%              fontSize    default = 8
% 
% Note that you can specify all, some, or none of these, in any order
%
% 'outParams' returns the parameters used (usually some mix of supplied and default)
% This is convenient if you don't like what you see and wish to know what a good
% rough starting value is for a given field.

function drawAxis(tickLocations, varargin)

% Tick labels
def.tickLabels = 'default';

% Locations of the numerical labels
def.tickLabelLocations = 'default';

% Any long ticks
def.longTicks = def.tickLabelLocations;  % default is labels get long ticks

% Length of the long ticks
def.extraLength = 0.55;

% specify a value here to position the axis line at this plus axisOffset 
% (e.g. 0 for axisOrientation=h means put the horizontal line at 0+offset
% if not specified, this will be set to the lower limit of the current axes limits
%
% Also, since drawAxis expands the current axes limits to incorporate the tick marks, 
% we use setappdata on the current axes to keep track of our changes to the axes limits
def.axisPosition = [];

% axis label (e.g. 'spikes/s')
def.axisLabel = '';

% Axis offset (vertical for a horizontal axis, and vice versa)
def.axisOffsetPercentage = 'default';

% choose horizontal or vertical axis
def.axisOrientation = 'h';  % horizontal is default

% normal or inverted axis (inverted = top for horizontal, rhs for vertical)
def.invert = false; % default is normal axis

% length of ticks
def.tickLength = 'default';

% offset of numerical tick labels from the ticks (vertical offset if using a horizontal axis)
def.tickLabelOffset = 'default';

def.tickAlignments = {};

% offset of axis label
def.axisLabelOffset = 'default';

% line thickness
def.lineThickness = 1; % default thickness is 1

% color
color = [];
def.color = 'k'; % default color is black

def.labelColors = 'k';

% font size
def.fontSize = 11; % default fontsize is 8 points (numerical labels are 1 pt smaller)

def = assignargs(def, varargin);

% ********** DONE PARSING INPUTS ***************

if isappdata(gca, 'drawAxisOrigLims')
    % this function has already been called on this axis, use the cached
    % original axes limits for axis position computations
    axLim = getappdata(gca, 'drawAxisOrigLims');
    axLimNew = getappdata(gca, 'drawAxisNewLims');
else
    axLim = axis;  % default values based on 'actual' axis size of figure
    axLimNew = axLim;
    % expand the maximum limits to include the maximal tick marks
    % do this here to avoid repeatedly expanding the axis
    setappdata(gca, 'drawAxisOrigLims', axLim);
    axis(axLim);
end
xMin = axLim(1);
xMax = axLim(2);
yMin = axLim(3);
yMax = axLim(4);

% if not specified, use the lower limit of the appropriate axis
if isempty(axisPosition)
    if axisOrientation == 'h'
        axisPosition = yMin; 
    else
        axisPosition = xMin;
    end
end

if ischar(axisOffsetPercentage) & strcmp(axisOffsetPercentage, 'default')
    if axisOrientation == 'h'
        axisOffsetPercentage = -1.5;
    else
        axisOffsetPercentage = -1.5;
    end
end

% figure out actual axisOffset from percentage
if axisOrientation == 'h'
    axisOffset = axisOffsetPercentage / 100 * (yMax-axisPosition);
else
    axisOffset = axisOffsetPercentage / 100 * (xMax - axisPosition);
end



if ischar(tickLabels) & strcmp(tickLabels, 'default')
    tickLabels = cell(length(tickLocations),1);
    for i = 1:length(tickLocations)
        tickLabels{i} = sprintf('%g', tickLocations(i)); % defaults to values based on the tick locations
    end
end

if ischar(tickLabelLocations) & strcmp(tickLabelLocations, 'default')
    tickLabelLocations = tickLocations; %defaults to the values specified by the labels themselves
end

if ischar(tickLength) & strcmp(tickLength, 'default')
    if axisOrientation == 'h'
        tickLength = abs(yMax-axisPosition)/100;
    else
        tickLength = abs(xMax-axisPosition)/100;
    end
end

if invert
    tickLength = -tickLength;
end

if ischar(tickLabelOffset) & strcmp(tickLabelOffset, 'default')
    tickLabelOffset = tickLength/2;
end

if ischar(axisLabelOffset) & strcmp(axisLabelOffset, 'default')
    if axisOrientation == 'h'
        axisLabelOffset = tickLength*6;
    else
        axisLabelOffset = tickLength*18; 
    end
end

% DETERMINE APPOPRIATE ALIGNMENT FOR TEXT (based on axis orientation)
if axisOrientation == 'h';  % for horizontal axis
    LalignH = 'center';  % axis label alignment
    if isempty(tickAlignments)
        NalignH = 'center';  % numerical labels alignment
    else
        NalignH = tickAlignments;
    end
    if invert==0        
        LalignV = 'top';        
        NalignV = 'top';
    else
        LalignV = 'bottom';
        NalignV = 'bottom';
    end
else                        % for vertical axis
    LalignH = 'center';  % axis label alignment   
    NalignV = 'middle';  % numerical labels alignment
    if invert==0 
        LalignV = 'bottom';  % axis label alignment
        NalignH = 'right';
    else
        LalignV = 'top';
        NalignH = 'left';
    end    
end


% PLOT AXIS LINE
% plot main line with any ending ticks as part of the same line
% (looks better in illustrator that way)
hold on;
start = min(tickLocations);
fin = max(tickLocations);
axisX = [start, fin];
axisY = axisPosition + axisOffset * [1, 1];
if ismember(start, tickLocations)
    tempLen = tickLength + tickLength*extraLength*ismember(start, longTicks);
    axisX = [start, axisX]; 
    axisY = [axisY(1)-tempLen,axisY]; 
end
if ismember(fin, tickLocations)
    tempLen = tickLength + tickLength*extraLength*ismember(fin, longTicks);
    axisX = [axisX, fin];
    axisY = [axisY, axisY(end)-tempLen];
end 
if axisOrientation == 'h', h = plot(axisX, axisY); else h = plot(axisY, axisX); end
set(h,'color', color, 'lineWidth', lineThickness);

% PLOT TICKS
for i = 1:length(tickLocations)
    if ~ismember(tickLocations(i),[start, fin]) % these have already been plotted
        tempLen = tickLength + tickLength*extraLength*ismember(tickLocations(i), longTicks);
        tickX =  tickLocations(i)*[1 1]; 
        tickY = axisPosition+axisOffset + [0 -tempLen];
        if axisOrientation == 'h', h = plot(tickX, tickY); else h = plot(tickY, tickX); end
        set(h,'color', color, 'lineWidth', lineThickness);
    end
end

% PLOT NUMERICAL LABELS (presumably on the ticks)
tickLim = tickLength + tickLength*extraLength*~isempty(longTicks); % longest tick length
for i = 1:length(tickLabelLocations)
    x = tickLabelLocations(i);
    y = axisPosition+axisOffset - tickLim - tickLabelOffset;
    if axisOrientation == 'h', h = text(x, y, tickLabels{i}); else h = text(y, x, tickLabels{i}); end
	if ischar(labelColors)
		thisColor = labelColors;
	elseif isnumeric(labelColors)
		if size(labelColors, 1) == length(tickLabels)
			thisColor = labelColors(i, :);
		else
			thisColor = labelColors;
		end
    end
	
    if iscell(NalignH)
        thisAlignH = NalignH{i};
    else
        thisAlignH = NalignH;
    end
    set(h,'HorizontalA', thisAlignH, 'VerticalA', NalignV, 'fontsize', fontSize-1, 'color', thisColor);
end

% PLOT AXIS LABEL
x = (start+fin)/2;
y = axisPosition + axisOffset - tickLim - axisLabelOffset;
if axisOrientation == 'h'
    h = text(x, y, axisLabel);
else
    h = text(y, x, axisLabel); 
end
set(h,'HorizontalA', LalignH, 'VerticalA', LalignV, 'fontsize', fontSize, 'color', color);
if axisOrientation == 'v', set(h,'rotation',90); end
% DONE PLOTTING

% expand axes limits to include 
if axisOrientation == 'v'
    axLimNew(1) = min(axLim(1), axisPosition+axisOffset-tickLength-axisLabelOffset);
    
    if axLimNew(4) <= fin
        axLimNew(4) = axLimNew(4) + diff(axLimNew(3:4))*0.01;
    end
else
    axLimNew(3) = min(axLim(3), axisPosition+axisOffset-tickLength-axisLabelOffset);
    
    if axLimNew(2) <= fin
        axLimNew(2) = axLimNew(2) + diff(axLimNew(1:2))*0.01;
    end
end
    
axis(axLimNew);
setappdata(gca, 'drawAxisNewLims', axLimNew);

end




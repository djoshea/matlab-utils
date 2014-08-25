function [hBar,hError] = barPlotWithError(x,y,e,varargin)
% function to plot bar plots with error bars

p = inputParser();
p.addParamValue('colors', [], @(x) isnumeric(x) || iscell(x));
p.addParamValue('baseline', 0, @isscalar);
p.addParamValue('baselineColor', [0.5 0.5 0.5], @(x) true);
p.addParamValue('barWidth', 0.8, @isscalar);
p.addParamValue('lineWidth', [], @isscalar);
p.addParamValue('labels', {}, @iscellstr);
%p.addParamValue('labelsAboveBar', {}, @iscellstr)
p.parse(varargin{:});

N = length(x);
colors = p.Results.colors;
if isempty(colors)
    colors = distinguishable_colors(N);
end

barWidth = p.Results.barWidth;
lineWidth = p.Results.lineWidth;
if isempty(lineWidth)
    lineWidth = barWidth / 20;
end
labels = p.Results.labels;
baseline = p.Results.baseline;
%labelsAboveBar = p.Results.labelsAboveBar;

%% Plot the bars

for i = 1:length(x)
    if iscell(colors)
        c = colors{i};
    else
        c = colors(i, :);
    end
    hBar(i) = bar(x(i), y(i));
    set(hBar(i), 'BarWidth', barWidth, 'FaceColor', c, 'EdgeColor', 'none');
    
    hold on
end

delete(get(hBar(i), 'Baseline'));

%% Plot the errorbars

hold on;
hError = nan(length(x), 1);
for i = 1:length(x)
    if iscell(colors)
        c = colors{i};
    else
        c = colors(i, :);
    end
    if y(i) < 0
        y0 = y(i) - e(i);
    else
        y0 = y(i) + e(i);
    end
    if e(i) > 0
        hError(i) = rectangle('Position', [x(i)-lineWidth/2, y0, lineWidth, 2*e(i)]);
        set(hError(i), 'FaceColor', 'k', 'EdgeColor', 'none');
    end
    hold on
end
for i = 1:length(hError)
    if ~isnan(hError(i))
        hasbehavior(hError(i), 'legend', false);
    end
end
hold off;

if ~isempty(labels)
    set(gca, 'XTick', x, 'XTickLabel', labels);
end
box off 

%% Plot baseline line

xl = get(gca, 'XLim');
if ~isempty(baseline)
    h = line(xl, [baseline, baseline], 'LineStyle', '-', 'Color', p.Results.baselineColor);
    set(h, 'YLimInclude', 'off', 'XLimInclude', 'off');
    hasbehavior(h, 'legend', false);
end


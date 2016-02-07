function [H, binsUsed] = HistISI(T, varargin)

% H = HistISI(TS, parameters)
%  H = HistISI(TS, 'maxLogISI','maxLogISI',5)      for fixed upper limit 10^5 msec (or 100 sec)
%
% INPUTS:
%      TS = a single ts object
%
% OUTPUTS:
%      H = histogram of ISI
%      N = bin centers
%
% PARAMETERS:
%     nBins 500
%     maxLogISI variable
%     minLogISI 
%
% If no outputs are given, then plots the figure directly.
%
% ADR 1998
% version L5.3
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.
%
% ADR 2 DEC 2003 fixed capitalizations
%
% Assumes data passed in are in seconds.

%--------------------
epsilon = 1e-100;
nBins = 500;
maxLogISI = 3;
minLogISI = -3;
axesHandle = [];

myTitle = '';
myFigureTag = 'HistISI';
myColor = 'b';

process_varargin(varargin);

if isa(T, 'ts'); 
	T = T.range();
end

binsUsed = nan; H = nan;

ISI = diff(T) + epsilon;
if isempty(ISI)
   warning('MClust:ISI','ISI contains no data!');
   return
end   
if ~isreal(log10(ISI))
   warning('MClust:ISI', 'ISI contains negative differences; log10(ISI) is complex.');
   complexISIs = true;
else
   complexISIs = false;
end

if isempty(maxLogISI)
    maxLogISI = max(real(log10(ISI)))+1;     
end

if isempty(minLogISI)
    minLogISI = floor(min(real(log10(ISI))));
end

binsUsed = logspace(minLogISI,maxLogISI,nBins);
H = histcn(ISI+eps, binsUsed);

%-------------------
if nargout == 0 || ~isempty(axesHandle)  % no output args, plot it
    if isempty(axesHandle)
        axesHandle = axes('Parent', figure('Tag', myFigureTag));
    end
    plot(axesHandle, binsUsed, H, '-', 'color', myColor); hold on
    plot([0.001 0.001], get(axesHandle, 'yLim'), 'r-', ...
        [0.002 0.002], get(axesHandle, 'yLim'), 'g-');
    hold off
    if complexISIs
        xlabel('ISI (s).  WARNING: contains negative components.');
    else
        xlabel('ISI (s).');
    end
    title(myTitle);
    set(gca, 'XScale', 'log', 'XLim', [10^minLogISI 10^maxLogISI]);
    if sum(ISI<0.002)>0
        text(min(get(axesHandle,'xLim')), max(get(axesHandle, 'yLim')), ...
            sprintf(' %d ISIs<2ms', sum(ISI<0.002)), ...
            'VerticalAlignment','top','HorizontalAlignment','left');
    end        
    set(gca, 'YTick', max(H));    
end
   


   
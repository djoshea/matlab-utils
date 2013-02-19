function [] = exportPlot(figHandle, filename, varargin)
% Export figures with 
%   a) better aesthetic defaults for axes, labels, title, etc.
%   b) size/color/format defaults.
%   c) if exporting eps, calls fixPSLinestyle to widen lines. Standard line
%   weight is too small, making grids and axes hard to view.
% 
% example usage:
%   exportPlot(gcf, 'figure_name')
%   exportPlot(gcf, 'figure_name', 'format', 'eps')
%   exportPlot(gcf, 'figure_name', 'size', [ 0 0 8.5 11])
% 
% emt 11/5/12
%
% todo: add padding if no x or y axis labels

% set defaults
defaultFormat = 'eps';
defaultSize = [0 0 6 6];
defaultColor = 'w';
defaultAxesShade = 0;

% input defaults
p = inputParser;
p.addRequired('figHandle');
p.addRequired('filename',@ischar);
p.addParamValue('format',defaultFormat);
p.addParamValue('size',defaultSize);
p.addParamValue('bgColor',defaultColor);
p.addParamValue('axesShade',defaultAxesShade);

% parse and deal inputs (yeah, this isn't the cleanest way to do this)
p.parse(figHandle,filename,varargin{:});
figHandle = p.Results.figHandle;
filename = p.Results.filename;
format = p.Results.format;
size = p.Results.size;
bgColor = p.Results.bgColor;
axesShade = p.Results.axesShade;

% fix defaults on all axes in figure
axesList = findall(figure(figHandle),'type','axes');

for kk = 1:length(axesList)
    axes(axesList(kk))
    set(gca, ...
        'Box'         , 'off'     , ...
        'TickDir'     , 'out'     , ...
        'TickLength'  , [.015 .015] , ...
        'XMinorTick'  , 'off'      , ...
        'YMinorTick'  , 'off'      , ...
        'XColor'      , axesShade*[1 1 1], ...
        'YColor'      , axesShade*[1 1 1], ...
        'LineWidth'   , 1         );
    
    set(gcf, 'InvertHardCopy', 'off');
    set(gca, 'TickDir','out')
    %set(get(gca,'XLabel'),'FontName', 'Arial',  'FontSize', 14);
    %set(get(gca,'YLabel'),'FontName', 'Arial',  'FontSize', 14);
    %set(get(gca,'ZLabel'),'FontName', 'Arial',  'FontSize', 14);
    %set(get(gca,'title') ,'FontName', 'Arial',  'FontSize', 16,  'FontWeight', 'bold');
    
end

% set background color
if bgColor == 'w'
    set(gcf,'Color','w')
else
    set(gcf,'Color','k')
end

orient portrait
set(gcf, 'PaperPosition', size);
% set(gcf, 'PaperPositionMode', 'auto');

% export in desired format
switch format
    case 'eps'      % default case
        print(figHandle,'-depsc2',[filename '_temp.eps']);
        fixPSlinestyle([filename '_temp.eps'],[filename '.eps']) % call external function to make line weights heavier
        eval(['!rm ' filename '_temp.eps']);
        
    case 'png'
%         set(gcf, 'PaperPosition', .5*size); %not sure why png requires rescaling
        print(figHandle,'-dpng', '-r300',filename);
        
    case 'svg'
        print(figHandle,'-dsvg','-r300', filename);
        
%     case 'epspng'
%         print(figHandle,'-depsc2',[filename '_temp.eps']);
%         fixPSlinestyle([filename '_temp.eps'],[filename '.eps']) % call external function to make line weights heavier
%         eval(['!rm ' filename '_temp.eps']);
%         
%         [pathstr, name, ext] = fileparts(filename);
%         mkdir([pathstr '/png/']);
%         print(figHandle,'-dpng', '-r300',[pathstr '/png/' name]);
        
end



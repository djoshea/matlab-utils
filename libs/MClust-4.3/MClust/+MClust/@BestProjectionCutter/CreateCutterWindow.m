function CreateCutterWindow(self)
% MClustCutter.CreateCutterWindow

MCS = MClust.GetSettings();
MCD = MClust.GetData();

self.CreateCutterWindow@MClust.Cutter(...
	'CreateAxesControls', false, ...
	'CreateHideShow', false);  % call superclass to build initial window

%--------------------------------
% constants to make everything identical

uicHeight = self.uicHeight;
uicWidth  = self.uicWidth;
uicWidth0 = self.uicWidth0;
uicWidth1 = self.uicWidth1;
XLocs = self.XLocs;
dY = self.dY;
YLocs = self.YLocs;

set(self.CC_figHandle, 'name','Cut on Best Projection subcutter');


% ----- axes

self.projectionPath = MClustUtils.NRadioSwitch(...
    {'Projection path 1', 'Projection path 2', 'Projection Path 3'}, ... %, 'Projection Path 4'}, ...
    'Parent', self.CC_figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1) YLocs(5) XLocs(2)-XLocs(1) uicHeight*4], ...
    'BackgroundColor', 'k', 'ForegroundColor', 'w', ...
    'SelectionChangeFcn', @(src,event)RecalculateProjection(self));

% ----- Drawing

% ----- Clusters
self.primaryClusterPanel = ...
    uipanel('Parent', self.CC_figHandle, ...
    'Units', 'Normalized', 'Position', [0 YLocs(1) XLocs(2) uicHeight]);

% --- undo/redo
self.undoButton = ...
    uicontrol('Parent', self.CC_figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1) YLocs(12) (uicWidth+uicWidth0)/2 uicHeight], ...
    'Style', 'pushbutton', 'String', 'Undo',  ...
    'Callback', @(src,event)PopUndo(self));
self.redoButton = ...
    uicontrol('Parent', self.CC_figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1)+(uicWidth+uicWidth0)/2 YLocs(12) (uicWidth+uicWidth0)/2 uicHeight], ...
    'Style', 'pushbutton', 'String', 'Redo',  ...
    'Callback', @(src,event)PopRedo(self));

% % Cutter options

% Load/Save/Clear clusters
	
self.append.SetB();
self.append.disable();


end
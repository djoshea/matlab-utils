function CreateCutterWindow(self)
% KKwikCutter.CreateCutterWindow

MCS = MClust.GetSettings();
MCD = MClust.GetData();

self.CreateCutterWindow@MClust.Cutter();  % call superclass to build initial window

%--------------------------------
% constants to make everything identical

uicHeight = self.uicHeight;
uicWidth  = self.uicWidth;
uicWidth0 = self.uicWidth0;
uicWidth1 = self.uicWidth1;
XLocs = self.XLocs;
dY = self.dY;
YLocs = self.YLocs;

set(self.CC_figHandle, 'name','SelectFromKKwik Cutting Control Window');

self.prevClusterButton = ...
    uicontrol('Parent', self.CC_figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1) YLocs(10) (uicWidth+uicWidth0)/2 uicHeight], ...
    'Style', 'pushbutton', 'String', 'PREV',  ...
    'Callback', @(src,event)PrevCluster(self));
self.nextClusterButton = ...
    uicontrol('Parent', self.CC_figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1)+(uicWidth+uicWidth0)/2 YLocs(10) (uicWidth+uicWidth0)/2 uicHeight], ...
    'Style', 'pushbutton', 'String', 'NEXT',  ...
    'Callback', @(src,event)NextCluster(self));


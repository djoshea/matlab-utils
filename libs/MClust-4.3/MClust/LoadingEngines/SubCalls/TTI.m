% handles to the controls, used in TTIcallback
global hTTIServer hTTITank hTTIBlock hTTIEvent hTTIListbox hTTILabel;

% variables to store selected information, used in TTIcallback
global TTICurrentServer;
global TTICurrentTank;
global TTICurrentBlock;
global TTICurrentEvent;
global TTICurrentChannel;

TTICurrentChannel = 1;

% data object that is loaded by RunAnalysis
global TTIdata;

TTICurrentServer = 'Local';
CALLBACK = 'TTIcallback';

% prog ID constants
SERVER_PROGID = 'SERVERSELECT.ServerSelectActiveXCtrl.1';
TANK_PROGID   = 'TANKSELECT.TankSelectActiveXCtrl.1';
BLOCK_PROGID  = 'BlockSelect.BlockSelectActiveXCtrl.1';
EVENT_PROGID  = 'EVENTSELECT.EventSelectActiveXCtrl.1';

% control positions
SERVER_POS = [12  319 221 90];
TANK_POS   = [12  19  221 286];
BLOCK_POS  = [250 219 202 190];
EVENT_POS  = [250 19  202 180];
BUTTON_POS = [500 19  60  51];
LABEL_POS  = [12  4   438 12];
TETSEL_POS = [455 19  38  160];

% add the TTI controls to the figure
hTTIServer = actxcontrol(SERVER_PROGID, SERVER_POS, hTTI, CALLBACK);
hTTITank   = actxcontrol(TANK_PROGID,   TANK_POS,   hTTI, CALLBACK);
hTTIBlock  = actxcontrol(BLOCK_PROGID,  BLOCK_POS,  hTTI, CALLBACK);
hTTIEvent  = actxcontrol(EVENT_PROGID,  EVENT_POS,  hTTI, CALLBACK);

% add button that links to RunAnalysis.m
hTTIButton = uicontrol('Position', BUTTON_POS, ...
    'Parent',    hTTI, ...
    'Style',    'pushbutton', ...
    'String',   'Load', ...
    'Callback', 'close(gcbf)');
    %'Callback', 'loadTDT');
    
    
% add status label controlled by TTIcallback
hTTIListbox = uicontrol('Position', TETSEL_POS, ...
    'Parent',   hTTI, ...
    'Style',    'listbox', ...
    'String',   '1|2|3|4|5|6|7|8', ...
    'Callback', CALLBACK);
    
% add status label controlled by TTIcallback
hTTILabel = uicontrol('Position', LABEL_POS, ...
    'Parent',   hTTI, ...
    'Style',    'text', ...
    'String',   'Status', ...
    'HorizontalAlignment', 'left');


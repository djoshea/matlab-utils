% handles all callbacks for TTImain
% there is usually no need to modify this
function TTIcallback(varargin)

% control handles
global hTTITank;
global hTTIBlock;
global hTTIEvent;
global hTTIListbox;
global hTTILabel;

% variables to hold current selections
global TTICurrentServer;
global TTICurrentTank;
global TTICurrentBlock;
global TTICurrentEvent;
global TTICurrentChannel;

% the listbox changed
if isempty(varargin)
    event = 'ListboxChanged';
    newvalue = get(hTTIListbox, 'Value');
else
    % grab the event and new value
    event = varargin{end};
    newvalue = varargin{3};
end

% handle the event
if strcmp(event, 'ServerChanged')
    TTICurrentServer = newvalue;
    %disp(['new server is ' TTICurrentServer]);
    
    % Process Server selection for TTI.TankSelect
    set(hTTITank, 'UseServer', newvalue);
    hTTITank.Refresh;
    
elseif strcmp(event, 'TankChanged')
    TTICurrentTank = newvalue;
    %disp(['new tank is ' TTICurrentTank]);
    
    % Process Server and Tank selection for TTI.BlockSelect
    set(hTTIBlock, 'UseServer', TTICurrentServer);
    set(hTTIBlock, 'UseTank', newvalue);
    
    % Deselects the previously selected Block if the current Tank is changed
    set(hTTIBlock, 'ActiveBlock', '');
    hTTIBlock.Refresh;
    
    % Deselects the previously selected Event and clears the event list if the current Tank is changed
    set(hTTIEvent, 'UseBlock', '');
    set(hTTIEvent, 'ActiveEvent', '');
    hTTIEvent.Refresh;
    
elseif strcmp(event, 'BlockChanged')
    TTICurrentBlock = newvalue;
    %disp(['new block is ' TTICurrentBlock]);
    
    % Process Server, Tank, and Block selection information for TTI.EventSelect
    set(hTTIEvent, 'UseServer', TTICurrentServer);
    set(hTTIEvent, 'UseTank', TTICurrentTank);
    set(hTTIEvent, 'UseBlock', TTICurrentBlock);
    
    % Deselects the previously selected Event if the current Block is changed
    set(hTTIEvent, 'ActiveEvent', '');
    hTTIEvent.Refresh;
    
elseif strcmp(event, 'ActEventChanged')
    TTICurrentEvent = newvalue;
    %disp(['new event is ' TTICurrentEvent]);
    
    % Process Event Selection and refresh
    hTTIEvent.Refresh;
    
elseif strcmp(event, 'ListboxChanged')
    TTICurrentChannel = newvalue;
    %disp(['new channel is ' num2str(TTICurrentChannel)]);
end

s = sprintf('%s; %s; %s; %s; %d', ...
    TTICurrentServer, TTICurrentTank, TTICurrentBlock, TTICurrentEvent, TTICurrentChannel);
set(hTTILabel, 'String', s);
end

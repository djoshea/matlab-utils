function [selection, OK] = nonmodal_listdlg(varargin)

% [selection, OK] = nonmodal_listdlg(varargin)
%
% variables are chosen to match Matlab's listdlg box
% code is modified from Matlab's listdlg code version 2012a

ListString = [];
SelectionMode = 'multiple';
ListSize = [160 300];
InitialValue = [1];
Name = '';
PromptString = {};
OKString = 'OK';
CancelString = 'Cancel';
fus = 8;
ffs = 8;
uh = 22;

varargin = process_varargin(varargin);

switch SelectionMode
    case 'single', smode = 1;
    case 'multiple', smode = 2;
    otherwise, error('Unknown selection mode.');
end

% figure size from Matlab's listdlg code
ex = get(0,'DefaultUicontrolFontSize')*1.7;  % height extent per line of uicontrol text (approx)
fp = get(0,'DefaultFigurePosition');
w = 2*(fus+ffs)+ListSize(1);
h = 2*ffs+6*fus+ex*length(PromptString)+ListSize(2)+uh+(smode==2)*(fus+uh);
fp = [fp(1) fp(2)+fp(4)-h w h];  % keep upper left corner fixed
btn_wid = (fp(3)-2*(ffs+fus)-fus)/2;


F = figure('name', Name, 'color', get(0,'DefaultUicontrolBackgroundColor'), ...
    'resize',                 'off', ...
    'numbertitle',            'off', ...
    'menubar',                'none', ...
    'windowstyle',            'normal', ...
    'createfcn',              '',    ...
    'position',               fp,   ...
    'KeyPressFcn', @doKeypress, ...
    'closerequestfcn',        'delete(gcbf)');

ListString = cellstr(ListString);

if ~isempty(PromptString)
    prompt_text = uicontrol(F, 'Style','text','String',PromptString,...
        'HorizontalAlignment','left',...
        'Position',[ffs+fus fp(4)-(ffs+fus+ex*length(PromptString)) ...
        ListSize(1) ex*length(PromptString)]);
end

listbox = uicontrol(F, 'Style','listbox',...
    'Position',[ffs+fus ffs+uh+4*fus+(smode==2)*(fus+uh) ListSize],...
    'String',ListString,...
    'BackgroundColor','w',...
    'Max',smode,...
    'Tag','listbox',...
    'Value',InitialValue);

ok_btn = uicontrol(F, 'Style','pushbutton',...
    'String',OKString,...
    'Position',[ffs+fus ffs+fus btn_wid uh],...
    'Tag','ok_btn',...
    'Callback',@doOK);

cancel_btn = uicontrol(F, 'Style','pushbutton',...
    'String',CancelString,...
    'Position',[ffs+2*fus+btn_wid ffs+fus btn_wid uh],...
    'Tag','cancel_btn',...
    'Callback',@doCancel);

if smode == 2
    selectall_btn = uicontrol(F, 'Style','pushbutton',...
        'String',getString(message('MATLAB:uistring:popupdialogs:SelectAll')),...
        'Position',[ffs+fus 4*fus+ffs+uh ListSize(1) uh],...
        'Tag','selectall_btn',...
        'Callback',@doSelectAll);
end

waitfor(F);


%% figure, OK and Cancel KeyPressFcn
    function doKeypress(~, evd)
        switch evd.Key
            case 'escape'
                doCancel();
        end
    end

%% OK callback
    function doOK(~, ~, ~)
        selection = get(listbox, 'Value');
        OK = true;
        delete(gcbf);
    end

%% Cancel callback
    function doCancel(~, ~, ~)
        selection = [];
        OK = false;
        delete(gcbf);
    end

%% SelectAll callback
    function doSelectAll(~, ~, ~)
        selection = 1:length(get(listbox, 'String'));
        OK = true;
        delete(gcbf);
    end


end
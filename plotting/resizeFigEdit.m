function resizeFigEdit(hvec)

if nargin < 1 || isempty(hvec)
    % prompt for figure files
    [file, path] = uigetfile('*.fig', 'Select MATLAB figure(s) to resize', 'MultiSelect', 'on');
    if isequal(file, 0)
        return;
    end
    fname = fullfile(path, file);
    if ischar(fname)
        fname = {fname};
    end

    % open each figure
    for iF = 1:numel(fname)
        figh = open(fname{iF});
        figh.WindowStyle = 'normal';

        % save file name in tag
        figh.Tag = dropExtension(figh.FileName);

    %     if ~isnan(w) && ~isnan(h)
    %         figSize(figh, [w h]);
    %     end

        addToolbar(figh);
    end
else
    % tag each figure
    for iF = 1:numel(hvec)
        figh = hvec(iF);
        figh.WindowStyle = 'normal';

        % try to guess a filename
        if isempty(figh.Tag)
             figh.Tag = dropExtension(figh.FileName);
        end 

    %     if ~isnan(w) && ~isnan(h)
    %         figSize(figh, [w h]);
    %     end

        addToolbar(figh);
    end
end
   
end

function name = dropExtension(fname)
    idLast = find(fname == '.', 1, 'last');
    if isempty(idLast)
        name = fname;
    else
        name = fname(1:idLast-1);
    end
end

function [w, h] = promptForSize(figh)
    % prompt for size
    prompt = {'Figure Width in cm (leave blank to maintain aspect ratio):', ...
        'Figure Height in cm (leave blank  to maintain aspect ratio)'};
    dlg_title = 'New figure size';
    num_lines = 1;
    
    set(figh, 'PaperUnits' ,'centimeters');
    set(figh, 'Units', 'centimeters');
    figPos = get(figh,'Position');
    defaultans = {num2str(figPos(3)),num2str(figPos(4))};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

    if isempty(answer)
        w = NaN;
        h = NaN;
    else
        w = str2double(answer{1});
        h = str2double(answer{2});
        figSize([w h], figh);
    end
end

function str = promptForTitle(figh)
    % prompt for size
    prompt = {'New title:'};
    dlg_title = 'Edit Title';
    num_lines = 1;
    
    axh = get(figh, 'CurrentAxes');
    defaultans = get(get(axh, 'Title'), 'String');
    if isempty(defaultans) || (iscell(defaultans) && isempty(defaultans{1}))
        [~, file, ext] = fileparts(figh.Tag);
        defaultans = {[file ext]};
    elseif ischar(defaultans)
        defaultans = {defaultans};
    end
        
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

    if isempty(answer)
        answer = '';
    end
    
    if isa(axh, 'matlab.graphics.GraphicsPlaceholder')
        title(answer);
    else
        title(axh, answer);
    end
    str = answer;
end
    

function saveToDisk(figh)
    fname = figh.Tag; 
    if isempty(fname)
        prompt = {'File name:'};
        dlg_title = 'Choose figure name';
        num_lines = 1;

        fname = inputdlg(prompt,dlg_title,num_lines,{''});
    end
    removeToolbar(figh);
    
    saveFigure(fname, figh, 'ext', {'fig', 'pdf'}, 'upsample', 6, 'painters', true);
    addToolbar(figh);
end

function tb = addToolbar(figh)
%     figh.ToolBar = 'none';
%     figh.MenuBar = 'none';
    figh.DockControls = 'off';
    tb = uitoolbar(figh, 'Tag', 'resizeFigEdit');

    % Save icon
    path = pathToThisFile;
    icon = loadIcon(fullfile(path, 'save_icon.png'));

    % Create a uipushtool in the toolbar
    p = uipushtool(tb,'TooltipString','Save',...
                     'ClickedCallback',...
                     @(varargin) saveToDisk(figh));
    p.CData = icon;
    
    % Resize button
    icon = loadIcon(fullfile(path, 'resize_icon.png'));
    p = uipushtool(tb,'TooltipString','Resize',...
                     'ClickedCallback',...
                     @(varargin) promptForSize(figh));
    p.CData = icon;
    
    % Title button
    p = uipushtool(tb,'TooltipString','Edit Title',...
                     'ClickedCallback',...
                     @(varargin) promptForTitle(figh));
    icon = loadIcon(fullfile(path, 'edit_icon.png'));
    p.CData = icon;
    
end

function removeToolbar(figh)
    figh.ToolBar = 'auto';
    figh.MenuBar = 'figure';
    figh.DockControls = 'on';
    
    h = findobj(figh, 'Tag', 'resizeFigEdit');
    delete(h);
end


function icon = loadIcon(file)
    scale =	@(x) (x - nanmin(x(:))) / (nanmax(x(:)) - nanmin(x(:)));
    icon = imread(file);    
    
    icon = imresize(icon, [22 22]);
    icon = padarray(icon, [2 2]);
    if size(icon, 3) == 1
        icon = repmat(icon, [1 1 3]);
    end
    icon = scale(-double(icon));
    icon(icon == 1) = NaN;
end

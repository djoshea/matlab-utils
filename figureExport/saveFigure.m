function saveFigure(varargin)
% saveFigure(hfig, name, ext)
%
% hfig : figure handle, default=gcf
% name : name for figure, default='out', as one of the following
%   string : string.ext will be used for each extension
%   cellstr : each entry corresponds to one extension
%   struct : name.(ext) will be used for each extension
%   function_handle : name(ext) must return the name
% ext : cell array of extensions, default={'fig', 'png', 'svg', 'eps', 'pdf'}

    extList = {'fig', 'png', 'hires.png', 'svg', 'eps', 'pdf'};

    p = inputParser;
    p.addOptional('hfig', gcf, @ishandle);
    p.addOptional('name', '', @(x) ischar(x) || iscellstr(x) || isstruct(x) || isa(x, 'function_handle'));
    p.addOptional('ext', extList, @(x) ischar(x) || iscellstr(x));
    p.KeepUnmatched = true;
    p.parse(varargin{:});
    hfig = p.Results.hfig;
    name = p.Results.name;
    ext = p.Results.ext;

    if ismember('fig', ext)
        file = getFileName('fig');
        
        printmsg('fig', file);
        saveas(hfig, file, 'fig');
    end
    
    % copy the figure
    hfigCopy = copyfig(hfig);
    set(hfigCopy, 'NumberTitle', 'off', 'Name', 'Copy of Figure -- Temporary');
        
    if ismember('png', ext)
        % set font to Myriad Pro
        figSetFont(hfigCopy, 'FontName', 'MyriadPro-Regular');
        file = getFileName('png'); 
        printmsg('png', file);
        export_fig(hfigCopy, file);
    end
    
    if ismember('hires.png', ext)
        % suppress large image warning
        s = warning('OFF', 'MATLAB:LargeImage');
        
        % set font to Myriad Pro
        figSetFont(hfigCopy, 'FontName', 'MyriadPro-Regular');
        file = getFileName('hires.png'); 
        printmsg('hires.png', file);
        export_fig(hfigCopy, file, '-r300');
        
        warning(s);
    end
    
    if ismember('svg', ext)
        % set font to Myriad Pro
        figSetFont(hfigCopy, 'FontName', 'MyriadPro-Regular');
        file = getFileName('svg');
        printmsg('svg', file);
        plot2svg(file, hfigCopy);
    end
    
    if ismember('eps', ext)
        % set everything to use a dummy font so that ghostscript can substitute
        figSetFont(hfigCopy, 'FontName', 'SUBSTITUTEFONT');
        file = getFileName('eps');
        printmsg('eps', file);
        export_fig(hfigCopy, file);
    end
    
    if ismember('pdf', ext)
        % set everything to use a dummy font so that ghostscript can substitute
        figSetFont(hfigCopy, 'FontName', 'SUBSTITUTEFONT');
        file = getFileName('pdf');
        printmsg('pdf', file);
        export_fig(hfigCopy, file);
    end
    
    close(hfigCopy);
    
    return;
    
%%%%%%%

    function printmsg(ex, file)
        debug('Saving %s as %s\n', ex, file);
    end
    
    function figSetFont(hfig, varargin);
        hfont = findobj(hfig, '-property', 'FontName');
        set(hfont, varargin{:});
        drawnow;
    end

    function file = getFileName(ex)
        if ischar(name)
            % append extension to name
            file = [name '.' ex];
        elseif iscell(name)
            % use corresponding name in cell array
            [~, ind] = ismember(ex, ext);
            file = name{ind};
        elseif isstruct(name)
            % lookup as field in array
            file = name.(ex);
        elseif isa(name, 'function_handle')
            file = name(ex);
        end

        % replace ~ with actual home directory, among other fixes
        file = GetFullPath(file);
    end
    
end
    

    

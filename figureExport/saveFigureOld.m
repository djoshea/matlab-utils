function fileList = saveFigure(varargin)
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
    extListDefault = extList;

    p = inputParser;
    p.addOptional('hfig', gcf, @ishandle);
    p.addOptional('name', '', @(x) ischar(x) || iscellstr(x) || isstruct(x) || isa(x, 'function_handle'));
    p.addOptional('ext', [], @(x) ischar(x) || iscellstr(x));
    p.addParamValue('convertFromPdf', true, @islogical);
    p.addParamValue('copy', true, @islogical);
    p.addParamValue('fixPcolor', true, @islogical);
    p.addParamValue('quiet', false, @islogical);
    p.KeepUnmatched = true;
    p.parse(varargin{:});
    hfig = p.Results.hfig;
    name = p.Results.name;
    ext = p.Results.ext;
    convertFromPdf = p.Results.convertFromPdf;
    fixPcolor = p.Results.fixPcolor;
    quiet = p.Results.quiet;

    if isempty(ext)
        % no extension list specified, figure out what it should be
        if isstruct(name)
            ext = fieldnames(name);
        elseif iscell(name)
            ext = cellfun(@getExtension, name, 'UniformOutput', false);
        else
            ext = extListDefault;
        end
    end 
    
    tempList = {};
    fileList = {};
    
    extNonRecognized = setdiff(ext, extList);
    if ~isempty(extNonRecognized)
        error('Extensions %s not supported', strjoin(ext, ', '));
    end
    
    if ismember('fig', ext)
        file = getFileName('fig');
        fileList{end+1} = file;
        
        if ~quiet
            printmsg('fig', file);
        end
        saveas(hfig, file, 'fig');
    end
    
    % copy the figure
    if p.Results.copy
        hfigCopy = copyfig(hfig);
        set(hfigCopy, 'NumberTitle', 'off', 'Name', 'Copy of Figure -- Temporary');
        
    else
        hfigCopy = hfig;
    end
    
    % bitmap formats are built using imagemagick to convert from pdf
    needPdfForConversion = any(ismember({'png', 'hires.png'}, ext)) && convertFromPdf;
        
    if ismember('pdf', ext) || needPdfForConversion
        if ismember('pdf', ext)
            % use the right file name
            file = getFileName('pdf');
            fileList{end+1} = file;
            if ~quiet
                printmsg('pdf', file);
            end
        else
            % use a temp file name
            file = [tempname '.pdf'];
            tempList{end+1} = file;
        end
        
        % set everything to use a dummy font so that ghostscript can substitute
        figSetFont(hfigCopy, 'FontName', 'SUBSTITUTEFONT');
        
        export_fig(hfigCopy, file, '-fixPcolor', true);   
        pdfFile = file;
    end
    
    if ismember('png', ext)
        file = getFileName('png'); 
        fileList{end+1} = file;

        if ~quiet
            printmsg('png', file);
        end
        
        % set font to Myriad Pro
        figSetFont(hfigCopy, 'FontName', 'MyriadPro-Regular');
        if convertFromPdf
            convertPdf(pdfFile, file);
        else
            export_fig(hfigCopy, file);
        end
    end
    
    if ismember('hires.png', ext)
        file = getFileName('hires.png'); 
        fileList{end+1} = file;
        if ~quiet
            printmsg('hires.png', file);
        end
        % set font to Myriad Pro
        figSetFont(hfigCopy, 'FontName', 'MyriadPro-Regular');
            
        if convertFromPdf
            convertPdf(pdfFile, file, true);
        else
            % suppress large image warning
            s = warning('OFF', 'MATLAB:LargeImage');
            export_fig(hfigCopy, file, '-r300');
            warning(s);
        end
    end
    
    if ismember('svg', ext)
        % set font to Myriad Pro
        figSetFont(hfigCopy, 'FontName', 'Myriad Pro');
        file = getFileName('svg');
        fileList{end+1} = file;

        if ~quiet
            printmsg('svg', file);
        end
        plot2svg(file, hfigCopy);
    end
    
    if ismember('eps', ext)
        % set everything to use a dummy font so that ghostscript can substitute
        figSetFont(hfigCopy, 'FontName', 'SUBSTITUTEFONT');
        fileList{end+1} = file;
        file = getFileName('eps');

        if ~quiet
            printmsg('eps', file);
        end
        export_fig(hfigCopy, file);
    end

    if p.Results.copy
        close(hfigCopy);
    end
    
    % delete temporary files
    for tempFile = tempList
        delete(tempFile{1});
    end
    
    return;
    
%%%%%%%

    function convertPdf(pdfFile, file, hires)
        % call imageMagick convert on pdfFile --> file
        if nargin < 3
            hires = false;
        end
        
        if hires
            density = 400;
            resize = 100;
        else
            density = 400;
            resize = 25;
        end
        
        % MATLAB has it's own older version of libtiff.so inside it, so we
        % clear that path when calling imageMagick to avoid issues
        cmd = sprintf('export LD_LIBRARY_PATH=""; export DYLD_LIBRARY_PATH=""; convert -verbose -trim -density %d %s -resize %d%% %s', ...
            density, escapePathForShell(pdfFile), resize, escapePathForShell(file));
        [status result] = system(cmd);
        
        if status
            fprintf('Error converting pdf file. Is ImageMagick installed?\n');
            fprintf(result);
            fprintf('\n');
        end
    end

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
    
    function ext = getExtension(file)
        [~, ~, dotext] = fileparts(file);
        if ~isempty(dotext)
            ext = dotext(2:end);
        else
            ext = '';
        end
    end
    
end
    

    

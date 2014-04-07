function fileList = saveFigureSvg(varargin)
% saveFigure(name, exts, figh)
%
% name : name for figure, default='out', as one of the following
%   string : string.ext will be used for each extension
%   cellstr : each entry corresponds to one extension
%   struct : name.(ext) will be used for each extension
%   function_handle : name(ext) must return the name
% hfig : figure handle, default=gcf
% ext : cell array of extensions, default={'pdf', 'png', 'svg'}

    extList = {'fig', 'png', 'hires.png', 'svg', 'eps', 'pdf'};
    extListDefault = {'pdf', 'png', 'svg'};

    p = inputParser;
    p.addOptional('name', '', @(x) ischar(x) || iscellstr(x) || isstruct(x) || isa(x, 'function_handle'));
    p.addOptional('ext', [], @(x) ischar(x) || iscellstr(x));
    p.addOptional('figh', gcf, @ishandle);
    p.addParamValue('copy', true, @islogical);
    p.addParamValue('quiet', true, @islogical);
    p.KeepUnmatched = true;
    p.parse(varargin{:});
    hfig = p.Results.figh;
    name = p.Results.name;
    ext = p.Results.ext;
    quiet = p.Results.quiet;

    if isempty(ext)
        % no extension list specified, figure out what it should be
        if isstruct(name)
            ext = fieldnames(name);
        elseif iscell(name)
            ext = cellfun(@getExtension, name, 'UniformOutput', false);
        elseif ischar(name)
            ext = getExtension(name);
        else
            ext = [];
        end
        
        if isempty(ext)
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
   
    % start with svg format, convert to pdf, then to other formats
    needSvg = any(ismember(setdiff(extList, 'fig'), ext));
    needPdf = any(ismember(setdiff(extList, {'fig', 'svg'}), ext));
    svgFile = '';
    pdfFile = '';
    
    if ismember('svg', ext) || needSvg
        if ismember('svg', ext)
            % use actual file name
            file = getFileName('svg');
            fileList{end+1} = file;
            if ~quiet
                printmsg('svg', file);
            end
        else
            % use a temp file name
            file = [tempname '.svg'];
            tempList{end+1} = file;
        end
        
        svgFile = file;
        
        % set font to Myriad Pro
        figSetFont(hfigCopy, 'FontName', 'Myriad Pro');
        plot2svg(file, hfigCopy);
    end
    
    if ismember('pdf', ext) || needPdf
        if ismember('pdf', ext)
            % use actual file name
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

        % convert to pdf using inkscape
        convertSvgToPdf(svgFile, file);
        
        pdfFile = file;
    end
    
    if ismember('png', ext)
        file = getFileName('png'); 
        fileList{end+1} = file;

        if ~quiet
            printmsg('png', file);
        end
        
        convertPdf(pdfFile, file);
    end
    
    if ismember('hires.png', ext)
        file = getFileName('hires.png'); 
        fileList{end+1} = file;
        if ~quiet
            printmsg('hires.png', file);
        end
        
        convertPdf(pdfFile, file, true);
    end
    
    if ismember('eps', ext)
        % set everything to use a dummy font so that ghostscript can substitute
        figSetFont(hfigCopy, 'FontName', 'SUBSTITUTEFONT');
        fileList{end+1} = file;
        file = getFileName('eps');

        if ~quiet
            printmsg('eps', file);
        end
        export_fig(hfigCopy, file, '-fixPcolor', true);
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

    function convertSvgToPdf(svgFile, pdfFile)
        % use Inkscape to convert pdf
        
        if ismac
            inkscapePath = '/Applications/Inkscape.app/Contents/Resources/bin/inkscape';
            if ~exist(inkscapePath, 'file')
                error('Could not locate Inkscape at %s', inkscapePath);
            end
        else
            inkscapePath = 'inkscape';
        end
        
        % MATLAB has it's own older version of libtiff.so inside it, so we
        % clear that path when calling imageMagick to avoid issues
        cmd = sprintf('export LD_LIBRARY_PATH=""; export DYLD_LIBRARY_PATH=""; %s --export-pdf=%s %s', ...
            inkscapePath, escapePathForShell(pdfFile), escapePathForShell(svgFile));
        [status, result] = system(cmd);
        
        if status
            fprintf('Error converting svg file. Is Inkscape configured correctly?\n');
            fprintf(result);
            fprintf('\n');
        end
    end

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
        cmd = sprintf('export LD_LIBRARY_PATH=""; export DYLD_LIBRARY_PATH=""; convert -verbose -density %d %s -resize %d%% %s', ...
            density, escapePathForShell(pdfFile), resize, escapePathForShell(file));
        [status, result] = system(cmd);
        
        if status
            fprintf('Error converting pdf file. Is ImageMagick installed?\n');
            fprintf(result);
            fprintf('\n');
        end
    end

    function printmsg(ex, file)
        debug('Saving %s as %s\n', ex, file);
    end
    
    function figSetFont(hfig, varargin)
        % set all fonts in the figure
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

%COPYFIG Create a copy of a figure, without changing the figure
%
% Examples:
%   fh_new = copyfig(fh_old)
%
% This function will create a copy of a figure, but not change the figure,
% as copyobj sometimes does, e.g. by changing legends.
%
% IN:
%    fh_old - The handle of the figure to be copied. Default: gcf.
%
% OUT:
%    fh_new - The handle of the created figure.

% Copyright (C) Oliver Woodford 2012
function fh = copyfig(fh)

    % Set the default
    if nargin == 0
        fh = gcf;
    end
    
    % store xlabel, ylabel, title visibility --> sometimes gets turned off
    xvis = get(get(gca, 'XLabel'), 'Visible');
    yvis = get(get(gca, 'YLabel'), 'Visible');
    zvis = get(get(gca, 'ZLabel'), 'Visible');
    tvis = get(get(gca, 'Title'), 'Visible');
    
    xpos = get(get(gca, 'XLabel'), 'Position');
    ypos = get(get(gca, 'YLabel'), 'Position');
    zpos = get(get(gca, 'ZLabel'), 'Position');
    tpos = get(get(gca, 'Title'), 'Position');
    
    % Is there a legend?
    if isempty(findobj(fh, 'Type', 'axes', 'Tag', 'legend'))
        % Safe to copy using copyobj
        fh = copyobj(fh, 0);
    else
        % copyobj will change the figure, so save and then load it instead
        tmp_nam = [tempname '.fig'];
        hgsave(fh, tmp_nam);
        fh = hgload(tmp_nam);
        delete(tmp_nam);
    end
    
    % restore visibility
    set(get(gca, 'XLabel'), 'Visible', xvis);
    set(get(gca, 'YLabel'), 'Visible', yvis);
    set(get(gca, 'ZLabel'), 'Visible', zvis);
    set(get(gca, 'Title'), 'Visible', tvis);
    
    set(get(gca, 'XLabel'), 'Position', xpos);
    set(get(gca, 'YLabel'), 'Position', ypos);
    set(get(gca, 'ZLabel'), 'Position', zpos);
    set(get(gca, 'Title'), 'Position', tpos);
end

    

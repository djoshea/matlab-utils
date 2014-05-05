function fileList = saveFigureSvg(varargin)
% saveFigure(name, exts, figh)
%
% Required
% name : name for figure(s), in one of the following forms:
%   string : 
%      if name has an extension at the end, only that format will be saved
%      if name has no extension at the end, extensions in exts will be
%        added
%   cellstr : each entry corresponds to one extension, names must have
%     valid extension
%   struct : field value .(ext) will be used for each extension ext
% 
% Optional:
% ext : list of extensions to use when name does not have extension already,
%       default={'pdf', 'png', 'svg'}
% figh : figure handle, [default=gcf]
%
% copy : copy the figure before saving to prevent modifications from
%   affecting the original figure. [default = true]
%
% quiet : print status messages [default = false]

    extListFull = {'fig', 'png', 'hires.png', 'svg', 'eps', 'pdf'};
    extListDefault = {'pdf', 'png', 'svg'};

    p = inputParser;
    p.addOptional('name', '', @(x) ischar(x) || iscellstr(x) || isstruct(x) || isa(x, 'function_handle'));
    p.addOptional('figh', gcf, @ishandle);
    p.addParamValue('ext', [], @(x) ischar(x) || iscellstr(x));
    p.addParamValue('copy', true, @islogical);
    p.addParamValue('quiet', true, @islogical);
    p.KeepUnmatched = true;
    p.parse(varargin{:});
    hfig = p.Results.figh;
    name = p.Results.name;
    ext = p.Results.ext;
    quiet = p.Results.quiet;

    % build a map with .ext = file with ext
    fileInfo = containers.Map('KeyType', 'char', 'ValueType', 'char');
    
    if isstruct(name)
        fields = fieldnames(name);
        for iF = 1:fields
            fileInfo(fields{iF}) = GetFullPath(name.(fields{iF}));
        end

    elseif iscell(name) % expect each argument to have extension already
        assert(isempty(ext), 'Extension list invalid with cell name argument');
        [extList] = cellfun(@getExtensionFromFile, name, 'UniformOutput', false);
        for iF = 1:length(ext)
            if ~ismember(extList{iF}, extList)
                error('Could not extract valid extension from file name %s', name{iF});
            end
            fileInfo(extList{iF}) = GetFullPath(name{iF});
        end

    elseif ischar(name) % may or may not have extension
        
        extFromName = getExtensionFromFile(name);
        if ismember(extFromName, extListFull)
            % single file name with extension
            assert(isempty(ext), 'Extension list invalid when name argument already has extension');
            fileInfo(extFromName) = GetFullPath(name);
        else
            % single file name with no extension, use extension list
            % (default if not found)
            if isempty(ext)
                ext = extListDefault; 
            end
            if ~iscell(ext)
                ext = {ext};
            end
            for iE = 1:numel(ext)
                fileInfo(ext{iE}) = GetFullPath(sprintf('%s.%s', name, ext{iE}));
            end
        end
    else
        error('Unknown format for argument name');
    end
    
    % check extensions
    extList = fileInfo.keys;
    nonSupported = setdiff(extList, extListFull);
    if ~isempty(nonSupported)
        error('Non-supported extensions %', strjoin(nonSupported, ', '));
    end
    
    fileList = {};
    tempList = {};
    
    % Save fig format
    if fileInfo.isKey('fig')
        file = fileInfo('fig');
        fileList{end+1} = file;
        if ~quiet
            printmsg('fig', file);
        end
        saveas(hfig, file, 'fig');
    end
    
    % copy the figure
    if p.Results.copy
        hfigCopy = copyfig(hfig);
        set(hfigCopy, 'NumberTitle', 'off', 'Name', 'Figure Copy -- Temporary');
    else
        hfigCopy = hfig;
    end
   
    % start with svg format, convert to pdf, then to other formats 
    needSvg = any(ismember(setdiff(extListFull, 'fig'), extList));
    needPdf = any(ismember(setdiff(extListFull, {'fig', 'svg'}), extList));
    svgFile = '';
    pdfFile = '';
    
    if fileInfo.isKey('svg') || needSvg
        if fileInfo.isKey('svg')
            % use actual file name
            file = fileInfo('svg');
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
    
    if fileInfo.isKey('pdf') || needPdf
        if fileInfo.isKey('pdf')
            % use actual file name
            file = fileInfo('pdf');
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
    
    if fileInfo.isKey('png')
        file = fileInfo('png');
        fileList{end+1} = file;

        if ~quiet
            printmsg('png', file);
        end
        
        convertPdf(pdfFile, file);
    end
    
    if fileInfo.isKey('hires.png')
        file = fileInfo('hires.png');
        fileList{end+1} = file;
        if ~quiet
            printmsg('hires.png', file);
        end
        
        convertPdf(pdfFile, file, true);
    end
    
    if fileInfo.isKey('eps')
        file = fileInfo('eps')
        fileList{end+1} = file;
        if ~quiet
            printmsg('eps', file);
        end
        convertPdf(pdfFile, file, true);
    end

    if p.Results.copy
        close(hfigCopy);
    end
    
    % delete temporary files
    for tempFile = tempList
        delete(tempFile{1});
    end
    
end
    

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
    fprintf('Saving %s as %s\n', ex, file);
end

function figSetFont(hfig, varargin)
    % set all fonts in the figure
    hfont = findobj(hfig, '-property', 'FontName');
    set(hfont, varargin{:});
    drawnow;
end

function [ext, fileSansExt] = getExtensionFromFile(file)
    [fPath, fName, dotext] = fileparts(file);
    if ~isempty(dotext)
        ext = dotext(2:end);
    else
        ext = '';
    end
    fileSansExt = fullfile(fPath, fName);
end

function str = strjoin(strCell, join)
    % str = strjoin(strCell, join)
    % creates a string by concatenating the elements of strCell, separated by the string
    % in join (default = ', ')
    %
    % e.g. strCell = {'a','b'}, join = ', ' [ default ] --> str = 'a, b'

    if nargin < 2
        join = ', ';
    end

    if isempty(strCell)
        str = '';
    else
        if isnumeric(strCell) || islogical(strCell)
            % convert numeric vectors to strings
            strCell = arrayfun(@num2str, strCell, 'UniformOutput', false);
        elseif iscell(strCell)
            strCell = cellfun(@num2str, strCell, 'UniformOutput', false);
        end
        
        strCell = cellfun(@num2str, strCell, 'UniformOutput', false);

        str = cellfun(@(str) [str join], strCell, ...
            'UniformOutput', false);
        str = [str{:}]; 
        str = str(1:end-length(join));
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
    
    hAxes = findobj(fh, 'Type', 'axes');
    nAxes = numel(hAxes);
    
    [xvis, yvis, zvis, tvis, zpos, ypos, zpos, tpos] = deal(cell(nAxes,1));
    
    for iAx = 1:nAxes
        axh = hAxes(iAx);
        
        % store xlabel, ylabel, title visibility --> sometimes gets turned off
        xvis{iAx} = get(get(axh, 'XLabel'), 'Visible');
        yvis{iAx} = get(get(axh, 'YLabel'), 'Visible');
        zvis{iAx} = get(get(axh, 'ZLabel'), 'Visible');
        tvis{iAx} = get(get(axh, 'Title'), 'Visible');

        xpos{iAx} = get(get(axh, 'XLabel'), 'Position');
        ypos{iAx} = get(get(axh, 'YLabel'), 'Position');
        zpos{iAx} = get(get(axh, 'ZLabel'), 'Position');
        tpos{iAx} = get(get(axh, 'Title'), 'Position');
    end

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
    
    hAxes = findobj(fh, 'Type', 'axes');
    for iAx = 1:nAxes
        axh = hAxes(iAx);
        
        % restore visibility
        set(get(axh, 'XLabel'), 'Visible', xvis{iAx});
        set(get(axh, 'YLabel'), 'Visible', yvis{iAx});
        set(get(axh, 'ZLabel'), 'Visible', zvis{iAx});
        set(get(axh, 'Title'), 'Visible',  tvis{iAx});

        set(get(axh, 'XLabel'), 'Position', xpos{iAx});
        set(get(axh, 'YLabel'), 'Position', ypos{iAx});
        set(get(axh, 'ZLabel'), 'Position', zpos{iAx});
        set(get(axh, 'Title'), 'Position', tpos{iAx});
    end
end

function File = GetFullPath(File)
% GetFullPath - Get absolute path of a file or folder [MEX]
% FullName = GetFullPath(Name)
% INPUT:
%   Name: String or cell string, file or folder name with or without relative
%         or absolute path.
%         Unicode characters and UNC paths are supported.
%         Up to 8192 characters are allowed here, but some functions of the
%         operating system may support 260 characters only.
%
% OUTPUT:
%   FullName: String or cell string, file or folder name with absolute path.
%         "\." and "\.." are processed such that FullName is fully qualified.
%         For empty strings the current directory is replied.
%         The created path need not exist.
%
% NOTE: The Mex function calls the Windows-API, therefore it does not run
%   on MacOS and Linux.
%   The magic initial key '\\?\' is inserted on demand to support names
%   exceeding MAX_PATH characters as defined by the operating system.
%
% EXAMPLES:
%   cd(tempdir);                    % Here assumed as C:\Temp
%   GetFullPath('File.Ext')         % ==>  'C:\Temp\File.Ext'
%   GetFullPath('..\File.Ext')      % ==>  'C:\File.Ext'
%   GetFullPath('..\..\File.Ext')   % ==>  'C:\File.Ext'
%   GetFullPath('.\File.Ext')       % ==>  'C:\Temp\File.Ext'
%   GetFullPath('*.txt')            % ==>  'C:\Temp\*.txt'
%   GetFullPath('..')               % ==>  'C:\'
%   GetFullPath('Folder\')          % ==>  'C:\Temp\Folder\'
%   GetFullPath('D:\A\..\B')        % ==>  'D:\B'
%   GetFullPath('\\Server\Folder\Sub\..\File.ext')
%                                   % ==>  '\\Server\Folder\File.ext'
%   GetFullPath({'..', 'new'})      % ==>  {'C:\', 'C:\Temp\new'}
%
% COMPILE: See GetFullPath.c
%   Run the unit-test uTest_GetFullPath after compiling.
%
% Tested: Matlab 6.5, 7.7, 7.8, 7.13, WinXP/32, Win7/64
% Compiler: LCC 2.4/3.8, OpenWatcom 1.8, BCC 5.5, MSVC 2008
% Author: Jan Simon, Heidelberg, (C) 2010-2011 matlab.THISYEAR(a)nMINUSsimon.de
%
% See also Rel2AbsPath, CD, FULLFILE, FILEPARTS.

% $JRev: R-x V:023 Sum:BNPK16hXCfpM Date:22-Oct-2011 00:51:51 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $UnitTest: uTest_GetFullPath $
% $File: Tools\GLFile\GetFullPath.m $
% History:
% 001: 20-Apr-2010 22:28, Successor of Rel2AbsPath.
% 010: 27-Jul-2008 21:59, Consider leading separator in M-version also.
% 011: 24-Jan-2011 12:11, Cell strings, '~File' under linux.
%      Check of input types in the M-version.
% 015: 31-Mar-2011 10:48, BUGFIX: Accept [] as input as in the Mex version.
%      Thanks to Jiro Doke, who found this bug by running the test function for
%      the M-version.
% 020: 18-Oct-2011 00:57, BUGFIX: Linux version created bad results.
%      Thanks to Daniel.

% Initialize: ==================================================================
% Do the work: =================================================================

% #############################################
% ### USE THE MUCH FASTER MEX ON WINDOWS!!! ###
% #############################################

% Difference between M- and Mex-version:
% - Mex-version cares about the limit MAX_PATH.
% - Mex does not work under MacOS/Unix.
% - M is remarkably slower.
% - Mex calls Windows system function GetFullPath and is therefore much more
%   stable.
% - Mex is much faster.

% Disable this warning for the current Matlab session:
%   warning off JSimon:GetFullPath:NoMex
% If you use this function e.g. under MacOS and Linux, remove this warning
% completely, because it slows down the function by 40%!
%warning('JSimon:GetFullPath:NoMex', ...
%  'GetFullPath: Using slow M instead of fast Mex.');

% To warn once per session enable this and remove the warning above:
%persistent warned
%if isempty(warned)
%   warning('JSimon:GetFullPath:NoMex', ...
%           'GetFullPath: Using slow M instead of fast Mex.');
%    warned = true;
% end

    % Handle cell strings:
    % NOTE: It is faster to create a function @cell\GetFullPath.m under Linux,
    % but under Windows this would shadow the fast C-Mex.
    if isa(File, 'cell')
       for iC = 1:numel(File)
          File{iC} = GetFullPath(File{iC});
       end
       return;
    end

    isWIN = strncmpi(computer, 'PC', 2);

    % DATAREAD is deprecated in 2011b, but available:
    hasDataRead = ([100, 1] * sscanf(version, '%d.%d.', 2) <= 713);

    if isempty(File)  % Accept empty matrix as input
       if ischar(File) || isnumeric(File)
          File = cd;
          return;
       else
          error(['JSimon:', mfilename, ':BadInputType'], ...
             ['*** ', mfilename, ': Input must be a string or cell string']);
       end
    end

    if ischar(File) == 0  % Non-empty inputs must be strings
       error(['JSimon:', mfilename, ':BadInputType'], ...
          ['*** ', mfilename, ': Input must be a string or cell string']);
    end

    if isWIN  % Windows: --------------------------------------------------------
       FSep = '\';
       File = strrep(File, '/', FSep);

       isUNC   = strncmp(File, '\\', 2);
       FileLen = length(File);
       if isUNC == 0                        % File is not a UNC path
          % Leading file separator means relative to current drive or base folder:
          ThePath = cd;
          if File(1) == FSep
             if strncmp(ThePath, '\\', 2)   % Current directory is a UNC path
                sepInd  = strfind(ThePath, '\');
                ThePath = ThePath(1:sepInd(4));
             else
                ThePath = ThePath(1:3);     % Drive letter only
             end
          end

          if FileLen < 2 || File(2) ~= ':'  % Does not start with drive letter
             if ThePath(length(ThePath)) ~= FSep
                if File(1) ~= FSep
                   File = [ThePath, FSep, File];
                else  % File starts with separator:
                   File = [ThePath, File];
                end
             else     % Current path ends with separator, e.g. "C:\":
                if File(1) ~= FSep
                   File = [ThePath, File];
                else  % File starts with separator:
                   ThePath(length(ThePath)) = [];
                   File = [ThePath, File];
                end
             end

          elseif isWIN && FileLen == 2 && File(2) == ':'   % "C:" => "C:\"
             % "C:" is the current directory, if "C" is the current disk. But "C:" is
             % converted to "C:\", if "C" is not the current disk:
             if strncmpi(ThePath, File, 2)
                File = ThePath;
             else
                File = [File, FSep];
             end
          end
       end

    else         % Linux, MacOS: ---------------------------------------------------
       FSep = '/';
       File = strrep(File, '\', FSep);

       if strcmp(File, '~') || strncmp(File, '~/', 2)  % Home directory:
          HomeDir = getenv('HOME');
          if ~isempty(HomeDir)
             File(1) = [];
             File    = [HomeDir, File];
          end

       elseif strncmpi(File, FSep, 1) == 0
          % Append relative path to current folder:
          ThePath = cd;
          if ThePath(length(ThePath)) == FSep
             File = [ThePath, File];
          else
             File = [ThePath, FSep, File];
          end
       end
    end

    % Care for "\." and "\.." - no efficient algorithm, but the fast Mex is
    % recommended at all!
    if ~isempty(strfind(File, [FSep, '.']))
       if isWIN
          if strncmp(File, '\\', 2)  % UNC path
             index = strfind(File, '\');
             if length(index) < 4    % UNC path without separator after the folder:
                return;
             end
             Drive            = File(1:index(4));
             File(1:index(4)) = [];
          else
             Drive     = File(1:3);
             File(1:3) = [];
          end
       else  % Unix, MacOS:
          isUNC   = false;
          Drive   = FSep;
          File(1) = [];
       end

       hasTrailFSep = (File(length(File)) == FSep);
       if hasTrailFSep
          File(length(File)) = [];
       end

       if hasDataRead
          if isWIN  % Need "\\" as separator:
             C = dataread('string', File, '%s', 'delimiter', '\\');  %#ok<REMFF1>
          else
             C = dataread('string', File, '%s', 'delimiter', FSep);  %#ok<REMFF1>
          end
       else  % Use the slower REGEXP in Matlab > 2011b:
          C = regexp(File, FSep, 'split');
       end

       % Remove '\.\' directly without side effects:
       C(strcmp(C, '.')) = [];

       % Remove '\..' with the parent recursively:
       R = 1:length(C);
       for dd = reshape(find(strcmp(C, '..')), 1, [])
          index    = find(R == dd);
          R(index) = [];
          if index > 1
             R(index - 1) = [];
          end
       end

       if isempty(R)
          File = Drive;
          if isUNC && ~hasTrailFSep
             File(length(File)) = [];
          end

       elseif isWIN
          % If you have CStr2String, use the faster:
          %   File = CStr2String(C(R), FSep, hasTrailFSep);
          File = sprintf('%s\\', C{R});
          if hasTrailFSep
             File = [Drive, File];
          else
             File = [Drive, File(1:length(File) - 1)];
          end

       else  % Unix:
          File = [Drive, sprintf('%s/', C{R})];
          if ~hasTrailFSep
             File(length(File)) = [];
          end
       end
    end

end

    

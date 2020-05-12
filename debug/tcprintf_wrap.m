function tcprintf(style, fmatString, varargin)
    % TCPRINTF Print colored output to the terminal
    %   tcprintf(style, fmatString, ...) works like fprintf(fmatString, ...)
    %   except that it uses the parameters in the style string to color or 
    %   underline the output using ANSI escape codes when using MATLAB from a
    %   terminal.. If not running in a terminal, or if called by MATLAB's
    %   datatipinfo function, tcprintf reverts to standard printf. The latter is
    %   desirable if tcprintf is used within an object's disp() method to avoid
    %   seeing the ANSI characters here.
    %  
    %   The first argument is an style description that consists of space-separated
    %   words. These words may include: 
    %  
    %   one of the following colors:
    %     black, red, green, yellow, blue, purple, cyan, darkGray, lightGray, white
    %  
    %   one of the following background colors:
    %     onBlack, onRed, onGreen, onYellow, onBlue, onPurple, onCyan, onWhite
    %  
    %   and any of the following modifiers:
    %     bright : use the bright (or bold) form of the color, not applicable for
    %         black, darkGray, lightGray, or white
    %     underline : draw an underline under each character
    %     blink : This is a mistake. Please don't use this ever.
    %  
    %   Example:
    %     tcprintf('lightGray onRed underline', 'Message: %20s\n', msg);
    %  
    %   Author: Dan O'Shea dan at djoshea.com (c) 2012
    %  
    %   Released under the open source BSD license 
    %     opensource.org/licenses/bsd-license.php


    if nargin > 0 && (nargin < 2 || ~ischar(style) || ~ischar(fmatString))
        error('Usage: tcprintf(style, fmatString, ...)');
    end
    
    if isempty(fmatString)
        return;
    end

    % determine if we're using 
    usingTerminal = ismember(getMatlabOutputMode(), {'terminal', 'notebook'});
    
    % determine if datatipinfo is higher on the stack. If tcprintf
    % is used within an object's disp() method, we don't want to
    % use color in the hover datatip or all you'll see are ANSI codes.
    stack = dbstack;
    inDataTip = ismember('datatipinfo', {stack.name});
    
    if nargin == 0
        if usingTerminal && ~inDataTip
            % clear the ansi codes in case somethings gone wrong
            fprintf('\033[0m');
        end
        return;
    end
    
    % generate the final string
    if isempty(fmatString)
        return;
    end
    fmatString = strrep(strrep(fmatString, '\{', '\\{'), '\}', '\\}'); 
    str = sprintf(fmatString, varargin{:});

    if strcmp(style, 'inline') || isempty(style)
        % use {style string} style inline tagging of format codes
        % style matches
        pat = '(?<style>(?<!\\){[^}]+})*(?<text>((\\{)|[^{])+)*';
        formatPairs = regexp(str, pat, 'names');
        for i = 1:numel(formatPairs)
            formatPairs(i).text = strrep(formatPairs(i).text, '\{', '{');
            formatPairs(i).text = strrep(formatPairs(i).text, '\}', '}');
        end
    else
        % use a single style element
        formatPairs.style = style;
        formatPairs.text = str;
    end
    
    % dump as plaintext if not in terminal or in data tip
    if ~usingTerminal || inDataTip
        % print the message without color wrapped to width and return
        textPieces = {formatPairs.text};
        str = [textPieces{:}];
        
        try
            jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
            cmdWin = jDesktop.getClient('Command Window');
            
            jTextArea = cmdWin.getComponent(0).getViewport.getComponent(0);
            width = jTextArea.getParent.getWidth();
            font = jTextArea.getParent().getFont();
            metrics = cmdWin.getFontMetrics(font);
            charWidth = metrics.charWidth('A');
            cols = floor(width/charWidth);
        catch
            cols = 80;
        end
        
        firstIndentedBy = find(str ~= ' ', 1, 'first');
        if isempty(firstIndentedBy)
            firstIndentedBy = 0; %#ok<NASGU>
            indentBy = 0;
        else
            firstIndentedBy = firstIndentedBy-1;
            indentBy = firstIndentedBy + 2;
        end
        wrapStr = sprintf('.{1,%d}\\s', cols-indentBy-4);
        str=regexprep(str, wrapStr, [blanks(indentBy) '$0\n']);
        if strlength(str) > indentBy && strcmp(str(1:indentBy), blanks(indentBy))
            str = str(indentBy+1:end-1); % strip indent on first line and strip trailing slash
        end
        fprintf('%s', str);
        return;
    end
    
    % parse all style strings
    stringCell = cell(1, 2*length(formatPairs));
    for iPair = 1:length(formatPairs)
        pair = formatPairs(iPair);
        [codeStr, noReset] = getCodeStringForStyle(pair.style); 
        stringCell{2*iPair-1} = makerow(codeStr);
        stringCell{2*iPair} = makerow(pair.text);
    end

    % concatenate the component strings
    contents = [stringCell{:}];
    %contents = sprintf(fullStr, varargin{:});
    
    % re-escape any %% that were transformed into % by sprintf
    contents = strrep(contents, '%', '%%');

    % evaluate the printf style message
    % if the message ends with a newline, we should turn off
    % formatting before the newline to avoid issues with 
    % background colors
    NEWLINE = newline;
    if ~isempty(contents) && contents(end) == NEWLINE
        contents = contents(1:end-1);
        endOfLine = NEWLINE; 
    else
        endOfLine = '';
    end
            
    if ~noReset
        str = [contents '\033[0m' endOfLine];
    else
        str = [contents endOfLine];
    end
    fprintf(str);
end

function [codeStr, noReset] = getCodeStringForStyle(style)
    if ~isempty(style) && style(1) == '{'
        style = style(2:end);
    end
    if ~isempty(style) && style(end) == '}'
        style = style(1:end-1);
    end
    tokens = regexp(style, '(?<value>\S+)[\s]?', 'names');
    values = {tokens.value};

    if isempty(style) || ismember('none', values)
        % handle return to default
        codes = 0;
        noReset = false;

    else
        [colorName, backColorName, bright, underline, blink, noReset] = parseStyleTokens(values);
        colorCodes = getColorCode(colorName, bright);
        if ~isempty(backColorName)
            backColorCode = getBackColorCode(backColorName);
        else
            backColorCode = [];
        end

        codes = [colorCodes; backColorCode];
        if underline
            codes = [codes; 4];
        end
        if blink
            codes = [codes; 5];
        end
    end

    % use \\ because this will be fed into fprintf
    codeStr = ['\033[', strjoin(codes, ';'), 'm'];
end

function [colorName, backColorName, bright, underline, blink, noReset] = parseStyleTokens(values)
    defaultColor = 'default';
    defaultBackColor = '';

    if ismember('bright', values)
        bright = true;
    else
        bright = false;
    end

    if ismember('underline', values)
        underline = true;
    else
        underline = false;
    end
    
    if ismember('blink', values)
        blink = true;
    else
        blink = false;
    end
    
    if ismember('noReset', values)
        noReset = true;
    else
        noReset = false;
    end

    % find foreground color
    colorList = {'black', 'darkGray', 'lightGray', 'red', 'green', 'yellow', ...
        'blue', 'purple', 'cyan', 'lightGray', 'white', 'default'};
    idxColor = find(ismember(colorList, values), 1);
    if ~isempty(idxColor)
        colorName = colorList{idxColor}; 
    else
        colorName = defaultColor;
    end

    % find background color
    backColorList = {'onBlack', 'onRed', 'onGreen', 'onYellow', 'onBlue', ...
        'onPurple', 'onCyan', 'onWhite', 'onDefault'};
    idxBackColor = find(ismember(backColorList, values), 1);
    if ~isempty(idxBackColor)
        backColorName = backColorList{idxBackColor}; 
    else
        backColorName = defaultBackColor;
    end

end

function colorCodes = getColorCode(colorName, bright)

    switch colorName
        case 'black'
            code = 30;
            bright = 0;
        case 'darkGray'
            code = 30;
            bright = 1;
        case 'red'
            code = 31;
        case 'green'
            code = 32;
        case 'yellow'
            code = 33;
        case 'blue'
            code = 34;
        case 'purple'
            code = 35;
        case 'cyan'
            code = 36;
        case {'gray', 'lightGray'}
            code = 37;
            bright = 0;
        case 'white'
            code = 37;
            bright = 1;
        case 'default'
            code = 39;
    end

    if bright
        colorCodes = [1; code];
    else
        colorCodes = [0; code];
    end

end

function colorCodes = getBackColorCode(colorName)

    switch colorName
        case 'onBlack'
            code = 40;
        case 'onRed'
            code = 41;
        case 'onGreen'
            code = 42;
        case 'onYellow'
            code = 43;
        case 'onBlue'
            code = 44;
        case 'onPurple'
            code = 45;
        case 'onCyan'
            code = 46;
        case 'onWhite'
            code = 47;
        case 'onDefault'
            code = 49;
    end

    colorCodes = code;
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
        end

        str = cellfun(@(str) [str join], strCell, ...
            'UniformOutput', false);
        str = [str{:}]; 
        str = str(1:end-length(join));
    end
end

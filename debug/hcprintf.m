function hcprintf(fmatString, varargin)
    % HCPRINTF Print true-colored output to the terminal with css styles hex
    % colors.
    % 
    % Example:
    % hcprintf('{blue} blue {#0000FF} blue {FF0000;000000}Red on black, {0,255,0; 255,255,255}Green on white, %d\n', 5);
    %
    % # is optional for hex codes, commas imply 
    % semicolon prefixes background color
    % 
    % Real braces should be escaped as \{ and \} to avoid being parsed as
    % colors.
    %
    % Color names will be passed through the XKCD color survey called as
    % 'rgb' by: Chad A. Greene of the University of Texas at
    % Austin's Institute for Geophysics.  I (Chad) do not claim credit for the data
    % from the color survey. http://www.chadagreene.com. 
    %
    % hcprintf Author: Dan O'Shea dan at djoshea.com (c) 2015
    % 
    %   Released under the open source BSD license 
    %     opensource.org/licenses/bsd-license.php
    
    % determine if we're using 
    usingTerminal = ismember(getMatlabOutputMode(), ["terminal", "notebook"]);

    % determine if datatipinfo is higher on the stack. If tcprintf
    % is used within an object's disp() method, we don't want to
    % use color in the hover datatip or all you'll see are ANSI codes.
    stack = dbstack;
    inDataTip = ismember('datatipinfo', {stack.name});
    
    if nargin == 0
        if usingTerminal && ~inDataTip
            % clear the ansi codes in case somethings gone wrong
            fprintf('\x1b[0m');
        end
        return;
    end
    
    str = sprintf(fmatString, varargin{:});
    
    tokenRegex = '{#?(?<fg>[\s0-9a-zA-Z,\.]+)?;?(?<bg>[\s0-9a-zA-Z,\.]+)?}';
    [content, colorspec] = regexp(str, tokenRegex, 'split', 'names');
    
    content = strrep(content, '\{', '{');
    content = strrep(content, '\}', '}');
    
     % dump as plaintext if not in terminal or in data tip
    if inDataTip
        fprintf(str);
        return;
    end
    
    if usingTerminal
    
        % parse and replace color strings with escape codes
        nSpec = numel(colorspec);
        escapeCodes = cell(1, nSpec+1); 
        for i = 1:nSpec
            fg = parseColorString(colorspec(i).fg);
            bg = parseColorString(colorspec(i).bg);

            if isempty(fg)
                if isempty(bg)
                    % neither
                    esc = '\x1b[0m';
                else
                    % bg only
                    esc = sprintf('\\x1b[48;2;%d;%d;%dm', bg);
                end
            else
                if isempty(bg)
                    % fg only
                    esc = sprintf('\\x1b[38;2;%d;%d;%dm', fg);
                else
                    % both
                    esc = sprintf('\\x1b[38;2;%d;%d;%d;48;2;%d;%d;%dm', fg, bg);
                end
            end

            escapeCodes{i} = esc;
        end
        escapeCodes{end} = '';

        % interleave content and escape codes
        combined = [content; escapeCodes];
        fmat = cat(2, combined{:});

        % if the message ends with a newline, we should turn off
        % formatting before the newline to avoid issues with 
        % background colors
        NEWLINE = char(10);
        if ~isempty(fmat) && fmat(end) == NEWLINE
            fmat = [fmat(1:end-1) '\x1b[0m\n'];
        else
            fmat = [fmat '\x1b[0m'];
        end

        % evaluate the printf style message
        fprintf(fmat, varargin{:});
        
    else
        % use Yair Altman's cprintf
        nSpec = numel(colorspec);
        fprintf(content{1});
        for i = 1:nSpec
            fg = parseColorString(colorspec(i).fg) / 255;
            if isempty(fg)
                cprintf('text', content{i+1}); % no formatting
            else
                cprintf(fg, content{i+1});
            end
        end
    end
end

function cvec = parseColorString(fg)
    fg = strtrim(fg);
    if isempty(fg) || strcmp(fg, 'none')
        cvec = [];
        return;
    end
    
    valid = '01234567890abcdefABCDEF,.';
    if ~all(ismember(fg, valid))
        % try xkcd lookup
        try
            cvec = round(rgb(fg) * 255); % THIS USES THE TOOL RGB!
        catch
            error('Could not parse color %s', fg);
        end
    else
        if contains(fg, ',')
            % is a R,G,B specification
            [red, rem] = strtok(fg, ',');
            cvec(1) = str2double(red);
            [gr, bl] = strtok(rem, ',');
            cvec(2) = str2double(gr);
            cvec(3) = str2double(bl);
        else
            % treat as hex
            if numel(fg) == 3
                cvec(1) = hex2dec(fg(1)) * 16;
                cvec(2) = hex2dec(fg(2)) * 16;
                cvec(3) = hex2dec(fg(3)) * 16;
            else
                cvec(1) = hex2dec(fg(1:2));
                cvec(2) = hex2dec(fg(3:4));
                cvec(3) = hex2dec(fg(5:6));
            end  
        end

        % convert floating point colors to 256
        if all(cvec <= 1)
            cvec = cvec * 255;
        end

        cvec = round(cvec);
    end
end


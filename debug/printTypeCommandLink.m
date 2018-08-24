function printTypeCommandLink(cmd, label, runWithNewline, newLineAfter)
    % label will be interpreted by hcprintf so '{azure}label' will be
    % printed in azure
    % 
    % in iTerm, relies on itermrun:// url handler which is provided with
    % this 
    
    if nargin < 3
        runWithNewline = false;
    end
    if nargin < 4
        newLineAfter = false;
    end
        
    usingTerminal = ~usejava('desktop');
    
    if usingTerminal
        % use default highlighting if no color specified
        if ~contains(label, '{')
            label = ['{azure}', label];
        end
    
        % use special itermrun:// url handler
        if ~runWithNewline
            url = ['itermrun://' encodeCmd(cmd)];
        else
            url = ['itermrun://' encodeCmd(cmd), '?newline=true'];
        end
    
        BEL = '\a';
        OSC8 = '\x1b]8';
        str = [OSC8 ';;', url, BEL, label, OSC8, ';;', BEL];
        if newLineAfter
            str = [str '\n'];
        end
        hcprintf(str);
    else
        % dump to command window using <a href="matlab:..."> syntax
        str = ['<a href="matlab:', cmd, '">', label, '</a>'];
        if newLineAfter
            str = [str '\n'];
        end
        fprintf(str);
    end
    
end

function cmd = encodeCmd(cmd)
    cmd = urlencode(cmd);
    cmd = strrep(cmd, '%', '%%');
    cmd = strrep(cmd, '+', '%%20'); % matlab's urlenmcode maps spaces to + 
end
function [rows cols] = getTerminalSize()
    usingTerminal = ~usejava('desktop');

    if (ismac || isunix) && usingTerminal
        cmd = 'tput lines';
        [s r] = unix(cmd);
        rows = sscanf(r, '%d');

        cmd = 'tput cols';
        [s r] = unix(cmd);
        cols = sscanf(r, '%d');
    else
        % use sensible defaults
        rows = 24;
        cols = 80;
    end
end

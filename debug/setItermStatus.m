function setItermStatus(message)

execpath = fullfile(getenv('HOME'), '.iterm2/it2setkeylabel');

if ~ismac || ~exist(execpath, 'file') || getMatlabOutputMode() ~= "terminal"
    return;
end

if contains(message, newline)
    message = extractBefore(message, newline);
end
cmd = sprintf('%s set status "%s"', execpath, message);
system(cmd);

end

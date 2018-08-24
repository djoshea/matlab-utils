function setItermStatus(message)

if contains(message, newline)
    message = extractBefore(message, newline);
end
cmd = sprintf('%s set status "%s"', fullfile(getenv('HOME'), '.iterm2/it2setkeylabel'), message);
system(cmd);

end

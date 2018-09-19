function setItermStatus(message)

if ismac && ~usejava('desktop') && exist(fullfile(getenv('HOME'), '.iterm2/it2setkeylabel'), 'file')

    if contains(message, newline)
        message = extractBefore(message, newline);
    end
    cmd = sprintf('%s set status "%s"', fullfile(getenv('HOME'), '.iterm2/it2setkeylabel'), message);
    system(cmd);
end

end

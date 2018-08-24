function dpi = getMacDPI()
    % get real pixels of screen
    [status, result] = system('osascript -e "tell application "Finder" to get bounds of window of desktop"');

    [status, result] = system('system_profiler SPDisplaysDataType | grep Resolution | cut -d : -f 2 | cut -d " " -f 2,4');
    try
        px = [1 1 sscanf(result, '%d')'];
    catch
    end
end

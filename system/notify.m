function notify(message, title)

if nargin < 2
    title = 'Matlab';
end
cmd = sprintf('terminal-notifier -message "%s" -title "%s"', message, title);
[r, s] = system(cmd);
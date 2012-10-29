function html = ansiToHtml(str)
% replace ansi escape codes with html spans

pat = '\033\[[\d;]*m';
html = regexprep(str, pat, ''); 

end

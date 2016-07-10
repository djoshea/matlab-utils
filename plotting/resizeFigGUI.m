function resizeFigGUI()

[file, path] = uigetfile('*.fig', 'Select MATLAB figure(s) to resize', 'MultiSelect', 'on');

if isequal(file, 0)
    return;
end

fname = fullfile(path, file);
    
% prompt for size
prompt = {'Figure Width in cm (leave blank to maintain aspect ratio):', ...
    'Figure Height in cm (leave blank  to maintain aspect ratio)'};
dlg_title = 'New figure size';
num_lines = 1;
defaultans = {'',''};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

w = str2double(answer{1});
h = str2double(answer{2});

% prompt for whether to append size to name
answer = questdlg('New file name?', 'File name', 'Append Size', 'Leave As-Is', 'AppendSize');
append =  strcmp(answer, 'Append Size');

% prompt for whether to append size to name
answer = questdlg('Remove titles?', 'Titles', 'Remove Titles', 'Leave Titles', 'Leave Titles');
remTitles =  strcmp(answer, 'Remove Titles');
    
if ischar(fname)
    fname = {fname};
end

for iF = 1:numel(fname)
    resizeFig(fname{iF}, w, h, 'appendSizeToName', append, 'removeTitles', remTitles);
end

end
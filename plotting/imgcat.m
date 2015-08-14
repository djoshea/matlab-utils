function imgcat(fname)
    % execute imgcat
    stack = dbstack('-completenames');
    d = fileparts(stack(1).file);
    d = strrep(d, ' ', '\ ');
    imgcatPath = fullfile(d, 'imgcat');
    system(['chmod u+x ' imgcatPath]);
    system([imgcatPath ' ' fname]);
end
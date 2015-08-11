function imgcat(fname)
    % execute imgcat
    stack = dbstack('-completenames');
    d = fileparts(stack(1).file);
    d = strrep(d, ' ', '\ ');
    imgcatPath = fullfile(d, 'imgcat');
    system(['chmod u+x ' imgcatPath]);
    system([imgcatPath ' ' fname]);
    
%     %fprintf('\033]1337;File=');
%     [r, s] = system(['echo -n ' fname ' | base64');
%     fprintf(r);
%     
%     [r, s] = system('echo -n ' fname ' | base64 -D | wc -c | awk ''printf "size=%d",' fname '}');
%     fprintf(r);
%     
%     ;inline=$2"
%     printf ":"
%     echo -n "$3"
%     printf '\a\n'
end
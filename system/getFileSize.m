function bytes = getFileSize(fname)
% gets file size ensuring that symlinks are dereferenced

if isunix
    cmd = sprintf('stat -Lc %%s %s', fname);
    [s, r] = system(cmd);
    bytes = str2double(r); 
else
    o = dir(fname);  
    bytes = o.bytes;
end

end
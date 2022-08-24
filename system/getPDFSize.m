function sz_cm = getPDFSize(filepath)
    filepath = escapePathForShell(filepath);
    shell  = "LD_LIBRARY_PATH='' pdfinfo " + filepath;
    [status, results] = system(shell);
    
    if status
        error('Error running pdf info %s', results);
    end

    results = string(results);
    lines = splitlines(results);

    ind = find(startsWith(lines, "Page size:", IgnoreCase=true), 1);
    if isempty(ind)
        error("Page size not found in pdfinfo output");
    end
    line = lines(ind);
    tokens = regexp(line, "Page size:\s*([\d\.]+) x ([\d\.]+) pts", 'tokens', 'once');
    sz_pts = str2double(tokens);
    sz_cm = sz_pts / 72 * 2.54;

    if nargout == 0
        fprintf('PDF size: %g x %g cm\n', sz_cm);
        clear sz_cm
    end
end
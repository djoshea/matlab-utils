function varargout = cellstrvec(N)
    vec = cell(N, 1);
    vec(:) = {''};
    [varargout{1:nargout}] = deal(vec);
end
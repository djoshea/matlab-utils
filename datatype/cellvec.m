function varargout = cellvec(N)
    [varargout{1:nargout}] = deal(cell(N, 1));
end
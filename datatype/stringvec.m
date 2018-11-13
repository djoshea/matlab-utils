function varargout = stringvec(N)
    [varargout{1:nargout}] = deal(strings(N, 1));
end
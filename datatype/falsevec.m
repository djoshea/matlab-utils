function varargout = falsevec(N)
    [varargout{1:nargout}] = deal(false(N, 1));
end
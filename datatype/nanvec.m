function varargout = nanvec(N)
    [varargout{1:nargout}] = deal(nan(N, 1));
end
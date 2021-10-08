function varargout = nanvec(N, varargin)
    [varargout{1:nargout}] = deal(nan(N, 1, varargin{:}));
end
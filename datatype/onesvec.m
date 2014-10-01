function varargout = onesvec(N, varargin)
    [varargout{1:nargout}] = deal(ones(N, 1, varargin{:}));
end
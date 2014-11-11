function varargout = zerosvec(N, varargin)
    [varargout{1:nargout}] = deal(zeros(N, 1, varargin{:}));
end
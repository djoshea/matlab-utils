function ic(varargin)

for i = 1:numel(varargin)
    fprintf("%s: %g\n", inputname(i), varargin{i});
end

end
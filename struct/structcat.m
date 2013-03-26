function S = structcat(varargin)
% Scat = structcat(S1, S2, [S3, ...])
% Concatenates multiple structures together by adding and ordering fields 
% as necessary via structEqualizeFields

if length(varargin) == 1 && iscell(varargin{1})
    varargin = varargin{1};
end

emptyMask = cellfun(@isempty, varargin);
varargin = varargin(~emptyMask);

structs = structEqualizeFields(varargin, 'ignoreEmpty', false);
structs = cellfun(@makecol, structs, 'UniformOutput', false);
S = cat(1, structs{:});

end

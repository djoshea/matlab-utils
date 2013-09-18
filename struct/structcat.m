function S = structcat(varargin)
% Scat = structcat(S1, S2, [S3, ...])
% Concatenates multiple structures together by adding and ordering fields 
% as necessary via structEqualizeFields

if length(varargin) == 1 && iscell(varargin{1})
    varargin = varargin{1};
end

emptyMask = cellfun(@isempty, varargin);
structs = makecol(varargin(~emptyMask));
clear varargin;

fieldsByElement = cellfun(@fieldnames, structs, 'UniformOutput', false);
fields = unique(cat(1, fieldsByElement{:}));
fieldsMissingByElement = cellfun(@(fieldsThis) setdiff(fields, fieldsThis), fieldsByElement, 'UniformOutput', false);

for iT = 1:length(structs)
    % add missing fields
    fieldsMissing = fieldsMissingByElement{iT};
    for iF = 1:length(fieldsMissing)
        structs{iT}.(fieldsMissing{iF}) = [];
    end
    structs{iT} = makecol(orderfields(structs{iT}, fields));
end
    
%structs = structEqualizeFields(varargin, 'ignoreEmpty', false);
%structs = cellfun(@makecol, structs, 'UniformOutput', false);
S = cat(1, structs{:});

end


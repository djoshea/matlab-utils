function [structCell fieldsAdded] = structEqualizeFields(structCell, varargin)
% [structCell fieldsAdded] = structEqualizeFields(structCell)
%
% Takes a cell array of structs and adds fields to each struct in the cell array to ensure that
% all of the structs have the exact same fields and field order
% fieldsAdded is a concatenated list of all fields added to each of the elements

def.verbose = true;
assignargs(def, varargin);

assert(iscell(structCell));

fieldsAdded = {};
nStructs = length(structCell);
for iAddTo = 1:nStructs
	for iToMatch = 1:nStructs
		if iAddTo == iToMatch
			continue;
		end

		[structCell{iAddTo} fieldsJustAdded]= structAddMissingFields(structCell{iAddTo}, structCell{iToMatch});
		fieldsAdded = union(fieldsAdded, fieldsJustAdded);
    end

    if ~isempty(structCell{iAddTo})
        structCell{iAddTo} = orderfields(structCell{iAddTo});
    end
end



function vals = structref(S, fld, varargin)
% structDeepRef(S, fld)
% returns an array (or cell array if necessary) similar to [S.(fld)], except
% that fld may use dots or ( ) indexing refer to nested structs, e.g.
%
% 	structDeepRef(S, 'a(1).b(2)') returns s.a(1).b(2) for every S(:)
%
% works only for shallow references at the moment though!!!

asCell = false;
assignargs(varargin);

nS = length(S);
if asCell
    vals = cell(nS,1);
else
    vals = nan(nS,1);
end

for iS = 1:nS
    val = S(iS).(fld);
    if asCell
        vals{iS} = val;
    elseif ~isempty(val)
        vals(iS) = val;
    end
end

return;

ref = struct();
iRef = 1;

% parse the field name by . tokens first
remain = fld;
while ~isempty(remain)
	% before the dot in token, remainder in remain (including dot)
	[token remain] = strtok(remain, '.');

	% chop the dot off the remainder
	if ~isempty(remain) && isequal(remain(1), '.')
		remain = remain(2:end);
	end

	% parse the reference in token:
	% fieldName(idx) with bracketType = '('
	% fieldName{idx) with bracketType = '{'

	info = regexp(token, '(?<fieldName>\w+)(?<bracketType>[\({]*)(?<idx>[\d:end-]*)[\)}]*', 'Names', 'once');

	% add dot reference
	ref(iRef).type = '.';
	ref(iRef).subs = info.fieldName;
	iRef = iRef + 1;

	% add indexed reference if necessary
	if ~isempty(info.bracketType)
		ref(iRef).type = info.bracketType;
		ref(iRef).subs = info.idx;
		iRef = iRef + 1;
	end
end


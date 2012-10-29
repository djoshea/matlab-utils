function spart = structslice(s, inds )
% SPART = structslice(s, inds) 
% indexes into each shallow field of a struct
% e.g. s.v = [1 2 3]; s.w = [3 2 1];
% then spart = structslice(s, [2 3]) has spart.v = [2 3], spart.w = [2 1];
    
flds = fieldnames(s);

spart = [];

% concatenate each field
for ifld = 1:length(flds)
    spart.(flds{ifld}) = s.(flds{ifld})(inds);
end

end



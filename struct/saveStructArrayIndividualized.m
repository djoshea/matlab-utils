function saveStructArrayIndividualized(fname, S, name, varargin)
% saveStructArrayIndividualized(fname, S, name, varargin)
% save a struct array S(:) as name1, name2, name3, ...
% allowing individual elements to be loaded quickly

N = length(S);

% build struct to save to disk
for i = 1:N
	fieldName = sprintf('%s_%d', name, i);
	saveStruct.(fieldName) = S(i);
end

save(fname, '-struct', 'saveStruct');


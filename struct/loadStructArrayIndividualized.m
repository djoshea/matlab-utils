function [S inds lookup] = loadStructArrayIndividualized(fname, name, indsFn, varargin)
% saveStructArrayIndividualized(fname, name, indsFn, varargin)
% loads a struct array S(:) saved as name1, name2, name3, ...
% allowing individual elements to be loaded quickly
%
% indsFn is either a list of inds to load, or a function that receives the 
% number of inds and the lookup table and returns the inds to load, alternatively you can request the lookup ahead of time and then ask for the inds directly

info = whos('-file', fname);
names = {info.name};

% check for the existence of successive vars from 1 up
lastIndFound = 0;
varNames = {};
while(true)
	varName = sprintf('%s_%d', name, lastIndFound + 1);

	if ismember(varName, names)
		% found it
		lastIndFound = lastIndFound + 1;
		varNames{lastIndFound} = varName;
	else
		break;
	end
end

if lastIndFound == 0
	% didn't find anything
	S = [];
	lookup = [];
	inds = [];
	return;
end

% load the lookup table
lookupName = sprintf('%s_lookup', name);
if ismember(lookupName, names)
	lookup = load(fname, lookupName);
else
	lookup = [];
end

if ~exist('indsFn', 'var') || isempty(indsFn)
	% no inds specified, load all
	inds = 1:lastIndFound;

elseif isnumeric(indsFn)
	% inds specified directly
	inds = indsFn;

elseif is_a(indsFn, 'function_handle')
	% we're handed a callback function, load the lookup table
	inds = indsFn(lastIndFound, lookup);
	if ~isnumeric(inds) 
		error('Index callback function must return a list of inds');
	end
	if max(inds) > lastIndFound || min(inds) < 1
		error('Indexes returned from callback function outside of valid range');
	end
end

% now grab the inds and load from the file
varNamesFiltered = varNames(inds);
data = load(fname, varNamesFiltered{:});

for i = 1:length(inds)
	S(i) = data.(varNamesFiltered{i});
end

if ~isempty(lookup)
	lookup = lookup(inds);
end

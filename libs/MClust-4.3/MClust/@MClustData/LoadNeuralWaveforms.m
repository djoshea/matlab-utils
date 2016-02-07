function WV = LoadNeuralWaveforms(self, records_to_get, key)

% MClust_LoadNeuralWaveforms
%    returns a TSD
%
%  calls appropriately constructed loading engines
%
%  fn = file name string
%  records_to_get = an array that is either a range of values
%  key = 1: timestamp list.(a vector of timestamps to load
%               (uses binsearch to find them in file))
%        2: record number list (a vector of records to load)
%        3: range of timestamps (a vector with 2 elements:
%                a start and an end timestamp)
%        4: range of records (a vector with 2 elements:
%                a start and an end record number)
%
% Only forwards the correct number of arguments
% ADR 2002
% Version M3.0
%
% Status: PROMOTED (Release version)
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

MCS = MClust.GetSettings();

fn = fullfile(self.TTdn, [self.TTfn self.TText]);

LoadingEngine = MCS.NeuralLoadingFunction;

switch nargin
	case 1
		[T,WV] = feval(LoadingEngine, fn);
	case 3
		[T,WV] = feval(LoadingEngine, fn, records_to_get, key);
	otherwise
		error('Incorrect parameters passed to MClust_LoadNeuralData');
end

WV = tsd(T, WV);

end


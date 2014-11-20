function splitSave(saveName, inArray)
%
% splitSave(saveName, inArray)
%
% v1 - paul - 2014/05/21
%
% save the input array of structures to saveName
% splitSave will split the input array into pieces so that no component is >2GB
%	this allows for the efficient saving to matlab format v6 which can be loaded quickly
%
%
% inArray - array of structures (e.g. R struct)
% saveName - 'filename' to save - can be local of full path
%	saveName will be a directory containing one or more mat files
%	if saveName exists as a directory, directory will be deleted and recreated
%	user must have write access to parent directory
%
% NOTE: assumes 1D array of structures, will NOT reconstruct >1D arrays
%		also assumes that data is roughly evenly distributed across array of structures
%
% example usage: splitSave('/tmp/R_1876-03-10', R);


%	maxVarSize = 2147483648; % 2GB
	maxVarSize = 1073741824; % 1GB

	existStatus = exist(saveName);
	if existStatus == 2 % file
		error('splitSave:saveName:ExistsAsFile', 'saveName provided exists as file, cannot create directory');
	end

	if existStatus == 7 % directory
		delSuccess = rmdir(saveName, 's'); % recursive delete
		if ~delSuccess
			error('splitSave:saveName:cannotDelete', 'cannot delete existing saveName, check permissions');
		end
	end

	mkdirSuccess = mkdir(saveName);

	if ~mkdirSuccess
		error('splitSave:saveName:cannotCreate', 'cannot create saveName directory, check permissions');
	end


	whosOut = whos('inArray');
	numSlices = ceil( whosOut.bytes / maxVarSize );
	numElements = numel(inArray);
	elementsPerSlice = floor( numElements / numSlices );


	if elementsPerSlice < 1
		fprintf('WARNING: array of structures too large, cannot slice small enough, saving as matlab v7.3\n');
		save( fullfile(saveName, sprintf('%04d.mat', 1)), inArray);
	else

		slices = [ 0 : elementsPerSlice : numElements ];
		if (elementsPerSlice * numSlices ~= numElements) % i.e. equal slicing left some elemenets at the end
			slices = [slices numElements];
			numSlices = numSlices + 1;
		end

		for i = 1 : numSlices
			splitData = inArray(slices(i) + 1 : slices(i + 1));
			save( fullfile(saveName, sprintf('%04d.mat', i)), '-v6', 'splitData' );
		end

	end

	infoFile = fopen(fullfile(saveName, 'info'), 'w+');
	fprintf(infoFile, 'v1');
	fclose(infoFile);

end

function [KKexpected] = RunOneKKwik(KKfn, FILEno, nKKFeatures, minClusters, maxClusters, varargin)
%
%  [status, KKexpected] = RunOneKKwik(KKfn, FILEno, nKKFeatures, minClusters, maxClusters, varargin)
%
% Parameters
%    USECONDOR = false
%    SubSetRate = 1  % for 1/10 use 0.1 % for 1/100 use 0.01

KKwikName = 'KlustaKwik.exe';
USECONDOR = false;
remote_pool = 'ADRLAB15.neuroscience.umn.edu';  % FOR USE WITH CONDOR
otherParms = '';
SubSetRate = 1;  

process_varargin(varargin);

% Find KKwik
MClustTarget = fileparts(which('MClust0'));
KKwikTarget = fullfile(MClustTarget, '+KlustaKwik', KKwikName);
if isempty(KKwikTarget)
	error('MClust:KKwik', 'Could not find %s to run.', KKwikName);
else
	fprintf('AutoCut with "%s".\n', KKwikTarget);
end

if SubSetRate > 1
    otherParms = sprintf('%s -Subset %d', otherParms, SubSetRate);
end
    
% Construct string
KKwikParms = ['-Screen 0 ', ...
	sprintf('-MinClusters %d ', minClusters), ...
	sprintf('-MaxClusters %d ', maxClusters), ...
	sprintf('-MaxPossibleClusters %d', maxClusters), ...    
	otherParms];
KKuseFeaturesString = ['-UseFeatures ' repmat('1',1,nKKFeatures)];

[fd fn ext] = fileparts(KKfn);
if isempty(fd), fd = pwd; end
disp(['KlustaKwiking ' fn ' ' num2str(FILEno)]);
KKwikCall = sprintf('"%s" "%s" %d %s %s', ...
	KKwikTarget, KKfn, FILEno, KKwikParms, KKuseFeaturesString);
KKexpected = sprintf('%s.clu.%d', fn, FILEno);

% Go!
if USECONDOR
	pushdir(fd);
	job_fname = [fn '.cdr'];
	fet_fname = sprintf('%s.fet.%d', fn, FILEno);
	
	[fid, msg] = fopen(job_fname, 'w');
	if ~isempty(msg)
		error('MClust:RunClustBatch:RunOneKKwik', msg);
	else		
		% save it and go
		fprintf(fid,'executable = %s\n',KKwikTarget);
		fprintf(fid,'universe = vanilla\n');
		fprintf(fid,'arguments = %s %d %s %s\n',...
			fn, FILEno, KKwikParms, KKuseFeaturesString);
		fprintf(fid,'output = %s.out\n',fn);
		fprintf(fid,'error = %s.error\n',fn);
		fprintf(fid,'log = %s.log\n',fn);
		fprintf(fid,'Requirements = (OpSys == "WINNT61" || OpSys =="WINNT51")\n');
		fprintf(fid,'should_transfer_files = YES\n');
		fprintf(fid,'when_to_transfer_output = ON_EXIT\n');
		fprintf(fid,'transfer_input_files = %s\n',fet_fname);
		fprintf(fid,'queue\n');
		
		fclose(fid);
		
		COMMAND = sprintf('!condor_submit -r %s %s', remote_pool, job_fname);
		COMD_output = evalc(COMMAND)
		
	end
	popdir;
else
	% run locally
	pushdir(fd);
	if exist(KKexpected, 'file')
		disp(['Skipping ' fn ' ' num2str(FILEno) '; ' KKexpected ' already generated.']);
    else
		status = system(KKwikCall);
	end
	popdir();
end
end


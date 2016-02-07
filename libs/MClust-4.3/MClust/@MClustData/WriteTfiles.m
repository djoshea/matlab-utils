function OK = WriteTfiles(self)

% Write T files (MClustData)

% ADR 2014-12-17
% now calls EraseTfiles to erase T files (so includes WV and CQ as well)
% now asks if want to erase if save with no clusters and there are previous
% .t or ._t files.

MCS = MClust.GetSettings();
MCD = self;

% ADR 2008 - delete .t set if replacing
fcT = FindFiles([MCD.TTfn '_*.t'], 'StartingDirectory', MCD.TTdn, 'CheckSubdirs', 0);
fc_T = FindFiles([MCD.TTfn '_*._t'], 'StartingDirectory', MCD.TTdn, 'CheckSubdirs', 0);
fc = cat(1, fcT, fc_T);

% ADR 2014-12-17
if isempty(MCD.Clusters)
    if ~isempty(fc)
        reply = questdlg({'There are no clusters, but there are previous .t or ._t files for this tetrode.','Do you want to erase them?'},...
            'Erase t files?', 'Yes', 'Cancel', 'Yes');
        if streq(reply, 'Yes')
            self.EraseTfiles();
        else
            OK = false;
            return
        end
    else
        OK = false;
        msgbox('There are no clusters to write.', 'WriteTFiles','warn');
        return
    end
end
  
% some of the clusters may be _t
if MCS.UseUnderscoreT
    names = cellfun(@(x)x.name, MCD.Clusters, 'UniformOutput', false);
    underscoreTclusters = listdlg(...
        'ListString', names, ...
        'Name', 'Files to save as _t', ...
        'PromptString', 'Which clusters should be saved as with an "_t" extension?', ...
        'OKString', 'DONE', 'CancelString', 'No _t files.', ...
        'InitialValue', []);    
else
    underscoreTclusters = [];
end

nClust = length(MCD.Clusters);

if ~isempty(fc)
	reply = questdlg({'There are already .t or ._t files for this tetrode.','Do you want to replace them?'},...
		'Overwrite t files?', 'Yes', 'Cancel', 'Yes');
	if streq(reply, 'Yes')
        self.EraseTfiles();
	else
		OK = false;
		return
	end
end
for iC = 1:nClust
   spikes = MCD.Clusters{iC}.GetSpikes();
   if ~isempty(spikes)
       
      tSpikes = MCD.FeatureTimestamps(spikes);
      
      if ismember(iC, underscoreTclusters)
          fn = [MCD.TfileBaseName(iC) '._' MCS.tEXT];
      else
          fn = [MCD.TfileBaseName(iC) '.' MCS.tEXT];
      end            
      
      fp = fopen(fn, 'wb', 'b');
      if (fp == -1)
         errordlg(['Could not open file"' fn '".']);
      end
      MClust.WriteHeader(fp, ...
          'T-file', ...
          'Output from MClust', ...
          'Time of spiking stored in timestamps (tenths of msecs)',...
          'as unsigned integer: uint32');
      switch MCS.tEXT
          case 'raw64'
              tSpikes = uint64(tSpikes); % 
              fwrite(fp, tSpikes, 'uint64');              
          case 't64'
              tSpikes = uint64(tSpikes*10000); % converts to 0.1 ms, but saves as 64bit 
              fwrite(fp, tSpikes, 'uint64');
          case 'raw32'
              tSpikes = uint32(tSpikes); % 
              fwrite(fp, tSpikes, 'uint32');                            
          case 't32'
              tSpikes = uint32(tSpikes*10000); % NEED TO CONVERT TO NEURALYNX's .t format save in integers of 0.1ms
              fwrite(fp, tSpikes, 'uint32');
          case 't'
              tSpikes = uint32(tSpikes*10000); % NEED TO CONVERT TO NEURALYNX's .t format save in integers of 0.1ms
              fwrite(fp, tSpikes, 'uint32');
          otherwise
              error('MClust::tEXT', 'Unknown extension for t files');
      end
       
      fclose(fp);
   end
end
OK = true;
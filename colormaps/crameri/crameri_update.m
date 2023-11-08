function crameri_update(release_major,zenodo_record_number)
% Retrieves all *relevant* CRAMERI data from ZENODO and collect it into a single .mat file 
% 
%% >> CRAMERI_UPDATE(release_major,zenodo_record_number)
%
%  • Unzips the requested(†) release from http://doi.org/10.5281/zenodo.1243862
%  • Navigates to the resulting dìrectory: …/ScientificColourMaps*/ (* = version)
%  • Imports all the colormaps, except the discrete-but-not-categorical ones
%  • Bundles everything in a single .mat archive, thus upgrading the package
%
%% EXAMPLES: crameri_update(7,5501399) or crameri_update('6','4153113')
%
% (†) TODO: we don't want to input the version details everytime we update...
%           > we'd better find a way to automatically point to the latest release
%             if no record number is provided. But ZENODO seems to fight back :(
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%crameri_update 
   %% Build the appropriate URL to ZENODO
   zver = string(release_major);
   zrec = string(zenodo_record_number);
   url1 = 'https://zenodo.org/record/';
   url2 = '/files/ScientificColourMaps';
   zurl = sprintf('%s%s%s%s.zip',url1,zrec,url2,zver);
   %% Entering the appropriate private path
   self = mfilename('fullpath'); 
   here = erase(self,'crameri_update'); cd(here)
   %% Download the .zip archive
   zipname = sprintf("ScientificColourMaps%s.zip", zver);
   if ~exist(fullfile('.', zipname), 'file')
       fprintf('Downloading artifact from ZENODO..')
       websave(zipname, zurl); fprintf('.DONE!\n\n')
   else
       fprintf('Found artifact from ZENODO already downloaded\n');
   end
   %% Extract and enter the directory
   fprintf('Unpacking the zip archive..')
   unzip(zipname,'./tmp/'); cd('./tmp/')
   fprintf('.DONE!\n\n'); clear();
   %% Retrieve all mat-files, recursively
   file = dir('./**/*.mat'); 
   %% Reshape into appropriate cell arrays
   name = {file(:).name};
   fold = {file(:).folder}; 
   %% Remove .mat extension from filenames
   name = erase(name,'.mat');
   %% Discard discrete-but-not-categorical cmaps
   %good = cellfun('isempty',regexp(name,'\d+$')); % \d+$: at least one digit at the end
   %name = name(good); fold = fold(good); % keep only the 'good' cell entries
   %% Load all 'good' mat-files and print to log
   for k = 1:length(name)
      fprintf("Importing colormap: '%s'\n",name{k})
      load([fold{k},'/',name{k},'.mat']); % better to restore extension: degenerate names!
   end
   %% Bundle everything in one mat-file
   fprintf('\nPacking the .mat archive..')
   clear('file','fold','name','good','k') % clean-up the workspace before saving
   save('CrameriColourMaps.mat'); fprintf('.DONE!\n\n');
   %% Final clean-up
   fprintf('Cleaning temporary files..')
   movefile('./CrameriColourMaps.mat','../CrameriColourMaps.mat'); cd ..
   rmdir('./tmp/','s'); delete('tmp.zip'); clear(); fprintf('.DONE!\n\n');
   
end
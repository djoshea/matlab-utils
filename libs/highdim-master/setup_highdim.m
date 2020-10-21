function setup_highdim

%% Setup path
baseDirectory = fileparts(mfilename('fullpath'));
addpath(genpath_ignoreHiddenDir(baseDirectory));

%% Compile DyadUpdate
if exist('+utils/mexDyadUpdate','file')~=3
    here = pwd;
    cd( fullfile(baseDirectory,'+utils') );
    disp('Compiling DyadUpdate code');
    mex -largeArrayDims -O mexDyadUpdate.c
    cd(here);
end

%% FJLT (Fast Hadamard) code
if exist('+utils/mexHadamard','file')~=3
    here = pwd;
    cd( fullfile(baseDirectory,'+utils') );
    disp('Compiling fast Hadamard code');
    if isunix
        % Assuming we are using gcc, so I know some fancier flags
        % This might make a difference on new computers (> 2012) that have AVX
        mex -O CFLAGS="\$CFLAGS -march=native -O3" mexHadamard.c -DNO_UCHAR
    else
        mex -O mexHadamard.c
    end
    cd(here);
end


function p = genpath_ignoreHiddenDir(d)
%%
% initialise variables
classsep = '@';  % qualifier for overloaded class directories
packagesep = '+';  % qualifier for overloaded package directories
p = '';           % path to be returned

% Generate path based on given root directory
files = dir(d);
if isempty(files)
  return
end

% Add d to the path even if it is empty.
p = [p d pathsep];

% set logical vector for subdirectory entries in d
isdir = logical(cat(1,files.isdir));
%
% Recursively descend through directories which are neither
% private nor "class" directories.
%
dirs = files(isdir); % select only directory entries from the current listing

for i=1:length(dirs)
   dirname = dirs(i).name;
   if    ~strcmp( dirname,'.')          && ...
         ~strcmp( dirname,'..')         && ...
         ~strncmp( dirname,classsep,1) && ...
         ~strncmp( dirname,packagesep,1) && ...
         ~strcmp( dirname,'private') && ...
         ~strcmpi( dirname(1), '.' ) % added in order to exclude .git/ files
      p = [p genpath(fullfile(d,dirname))]; % recursive calling of this function.
   end
end

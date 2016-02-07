function NEWDIR = popdir(all);

% NEWDIR = popdir
% NEWDIR = popdir 'all'
%
% Pops the top directory off the current stack.
% cds to it.

% ADR 1998
% version L4.1
% status PROMOTED

% allows popdir all now

global DIRSTACK

switch nargin
case 1
   if strcmp(all, 'all')
      if ~isempty(DIRSTACK)
         NEWDIR = DIRSTACK{length(DIRSTACK)};
         cd(NEWDIR);
         DIRSTACK = {};
      end
   else 
      error('Unknown input arguments.');
   end
case 0
   if isempty(DIRSTACK)
      disp('Directory stack empty.');
   else
      NEWDIR = DIRSTACK{1};
      cd(NEWDIR);
      DIRSTACK = DIRSTACK(2:length(DIRSTACK));
   end 
otherwise
   error('Unknown input arguments.');
end

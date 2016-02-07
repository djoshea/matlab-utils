function MClust

% MClust 
% 
% This version is packaged and uses object-oriented classes to provide
% safer code.
%
% ADR 1998
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.5.
% Version control M4.0 Dec/2012

%---------------------------------
% Check if instance exists
if any(strcmp(who('global'), 'MClustInstance'))
    error('MClust:Initialize', 'MClust is already running.');
end

global MClustInstance

%----------------------------------
% -- initialize
MClustInstance = MClust0();
MClustInstance.Initialize();

disp(MClust.GetSettings().VERSION)



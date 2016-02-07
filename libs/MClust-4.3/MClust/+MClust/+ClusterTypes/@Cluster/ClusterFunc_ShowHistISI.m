function ClusterFunc_ShowHistISI(self)
% ShowHistISI(self)
%
% NONE

% ADR 2003
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.
% Extensively modified by ADR to accomodate new ClusterOptions methodology
% v3.1 JCJ 2007: Added extra plot info
% ADR removed extraneous +1

MCS = MClust.GetSettings();

T = self.GetSpikeTimes();
MClust.HistISI(T, ...
    'myTitle', ['ISI histogram - ' self.name], ...
    'myFigureTag', MCS.DeletableFigureTag);

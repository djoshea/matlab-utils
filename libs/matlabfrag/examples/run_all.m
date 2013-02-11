%% Clean up.
close all;
clear all;
clc;
%% Comparisons
%  Run the comparisons first, because LaPrint requires
%  the figure number. Seriously, wtf?
if exist('laprint','file')
  run comparison01;
  close all;
  run comparison02;
  close all;
else
  warning('run_all:noLaPrint','LaPrint not found. Skipping the comparisons');
end
%% Run the scripts
numExamples = 17;
for ii=1:numExamples
  run( sprintf('ex%02i',ii) );
end
%% Run the extra testing scripts
numTests=16;
for ii=1:numTests
  run( sprintf('test%02i',ii) );
end
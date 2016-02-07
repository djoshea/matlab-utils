function tso = smooth(tsa, sigma, window)

% function tso = smooth(tsa, sigma, window)
%
% Smooths the the elements of a tsd 
% to apply to x,y run sd.x = SmoothPath(sd.x); sd.y = SmoothPath(sd.y);
%
% PARMS
% sigma % in seconds
% window % in seconds  
%
% builds a gaussian smoothing function (stdev = sigma) of nW (window/dt)
% elements on each side
%
% ADR Nov 2012

nW = ceil(window/tsa.dt);

w = (-nW:nW) * tsa.dt;

SmoothingWindow = normpdf(w,0,sigma);
SmoothingWindow = SmoothingWindow/sum(SmoothingWindow);

tso = ctsd(tsa.starttime, tsa.dt, conv2(tsa.data, SmoothingWindow', 'same'));



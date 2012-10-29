function [yDetrend slope] = detrendScatter(x,y, varargin)
% removes the linear (or polynomial, specify degree in n) relationship between X and Y from Y
% but preserves the same mean

def.polyDegree = 1;
assignargs(def, varargin);

p = polyfit(x,y,polyDegree);
yFromFit = polyval(p,x);
yDetrend = y - yFromFit + mean(yFromFit);

slope = p(end-1);

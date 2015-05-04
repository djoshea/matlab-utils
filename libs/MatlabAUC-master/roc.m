% ROC                         Receiver operating characteristic curve
% 
%     [tp,fp] = roc(data);
%
%     INPUTS
%     data - Nx2 matrix [t , y], where
%            t - a vector indicating class value (>0 positive class, <=0 negative)
%            y - score value for each instance
%
%     OUTPUTS
%     tp   - true positive rate
%     fp   - false positive rate
%
%     EXAMPLES
%     % Classic binormal ROC. 100 samples from each class, with a unit mean separation
%     % between the classes.
%     >> mu = 1;
%     >> y = [randn(100,1)+mu ; randn(100,1)];
%     >> t = [ones(100,1) ; zeros(100,1)];
%     >> [tp,fp] = roc([t,y])
%     >> plot(fp,tp);
%     
%     REFERENCE
%     Tom Fawcett. ROC Graphs: Notes and practical considerations (Algorithm 3)
%     Hewlett Packard Technical report 2003-4

%     $ Copyright (C) 2014 Brian Lau http://www.subcortex.net/ $
%     The full license and most recent version of the code can be found on GitHub:
%     https://github.com/brian-lau/MatlabAUC
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     REVISION HISTORY:
%     brian 03.08.08 written based on http://theoval.sys.uea.ac.uk/matlab/roc/roc.m
%                    Copyright G.C. Cawley under GPLv2
%                    with the ability to handle ties

function [tp,fp] = roc(data)

if size(data,2) ~= 2
   error('Incorrect input size in ROC!');
end

t = data(:,1);
y = data(:,2);

% process targets
t = t > 0;

% sort by classifier output
[Y,idx] = sort(-y);
t = t(idx);

% compute true positive and false positive rates
tp = cumsum(t)/sum(t);
fp = cumsum(~t)/sum(~t);

% handle equally scored instances (BL 030708, see pg. 10 of Fawcett)
[uY,idx] = unique(Y);
tp = tp(idx);
fp = fp(idx);

% add trivial end-points
tp = [0 ; tp ; 1];
fp = [0 ; fp ; 1];

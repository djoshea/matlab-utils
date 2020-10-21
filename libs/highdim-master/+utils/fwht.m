% FWHT                        Fast Discrete Walsh-Hadamard Transform
% 
%     Y = fwht(X)
%
%     Wrapper for efficient mex version of FWHT (mexHadamard.c).
%
%     INPUTS
%     X - input matrix or column vector
%
%     OUTPUTS
%     Y - transformed data

function Y = fwht(X)

[n,m] = size(X);
n2 = nextpow2(n);

% Zero-pad to nextpow2
if n ~= 2^n2
   X = [X ; zeros(2^n2-n,m)];
end

try
   % Scaled to match Matlab fwht
   Y = utils.mexHadamard(X)/2^n2;
catch err
   if strcmp(err.identifier,'MATLAB:UndefinedFunction')
      warning('fwht:mex',...
         sprintf(['Mex file ''mexHadamard.c'' has not be compiled\n'...
         'Transform will be done with slow Matlab version.']));
      Y = fwht(X,2^n2,'hadamard');
   else
      rethrow(err);
   end
end
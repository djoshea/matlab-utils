function [C,IA,IC] = nanunique(A, varargin)
    A = removenan(A(:));
    [C,IA,IC]  = unique(A, varargin{:});
end
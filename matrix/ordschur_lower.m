function [Qs, Ts] = ordschur_lower(Q, T, varargin)
% exactly like ordeig but for lower triangular T produced by schur_lower_real
% note that the ordering starts at the lower right corner and proceeds up and to the left though

    [Qu, Tu] = lower_to_upper(Q, T);
    
    [Qsu, Tsu] = ordschur(Qu, Tu, varargin{:});
    
    [Qs, Ts] = upper_to_lower(Qsu, Tsu);
    
    % for testing, norms should be very close to zero
%     A = Q * T * Q';
%     norm(Qu * Tu * Qu' - A, 'fro')
%     norm(QS * TS * QS' - A, 'fro')
end

function [Qu, Tu] = lower_to_upper(Ql, Tl)
    R = flipud(eye(size(Tl)));
    Tu = R' * Tl * R';
    Qu = Ql * R;
    
    norm(Ql * Tl * Ql' - Qu * Tu * Qu', 'fro')
end

function [Ql, Tl] = upper_to_lower(Qu, Tu)
    R = flipud(eye(size(Tu)));
    Tl = R' * Tu * R';
    Ql = Qu * R;
    
    norm(Ql * Tl * Ql' - Qu * Tu * Qu', 'fro')
end

